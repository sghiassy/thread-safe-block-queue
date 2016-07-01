//
//  ThreadSafeBlockQueue.m
//  Pods
//
//  Created by Shaheen Ghiassy on 6/27/16.
//
//

#import "ThreadSafeBlockQueue.h"
#import "ThreadSafeBlockModel.h"

@interface ThreadSafeBlockQueue ()

// Config
@property (nonatomic, readwrite, copy) NSString *name;

// Objects
@property (nonatomic, strong) NSMutableArray *blocks;

// Threads
@property (nonatomic, strong) dispatch_queue_t serialQueue; // the queue that all operations are run on inside this datastructure

// State
@property (atomic, readwrite, assign) ThreadSafeBlockQueueStates currentState;

@end


@implementation ThreadSafeBlockQueue

#pragma mark - Object Lifecycle

- (instancetype)init {
    return [self initWithName:@""];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];

    if (self) {
        // Instantiate Objects
        _name = [name copy];
        _currentState = ThreadSafeBlockQueueRunning;
        _serialQueue = dispatch_queue_create("com.Groupon.ThreadSafeBlockQueue", DISPATCH_QUEUE_SERIAL);
        _blocks = [[NSMutableArray alloc] init];

        [self suspendQueue];
    }

    return self;
}

- (void)dealloc {
    BOOL isStopped = self.currentState == ThreadSafeBlockQueueStopped;

    // You can't dealloc a suspended queue: http://stackoverflow.com/a/9572316/1179897
    if (isStopped) {
        [self startQueue];
    }

    _serialQueue = nil;
}

#pragma mark - Start / Stop Methods

- (void)startQueue {
    BOOL alreadyRunning = self.currentState == ThreadSafeBlockQueueRunning;

    if (alreadyRunning) {
        return;
    }

    dispatch_resume(_serialQueue);
    self.currentState = ThreadSafeBlockQueueRunning;
}

- (void)suspendQueue {
    BOOL alreadySuspended = self.currentState == ThreadSafeBlockQueueStopped;

    if (alreadySuspended) {
        return;
    }

    dispatch_suspend(_serialQueue);
    self.currentState = ThreadSafeBlockQueueStopped;
}

#pragma mark - Queue Methods

- (void)queueBlock:(void(^)(void))block {
    [self queueBlock:block shouldReplay:YES];
}

- (void)queueBlock:(void(^)(void))block shouldReplay:(BOOL)shouldReplay {
    if (block == nil) {
        return; // return early if we weren't provided a block to run
    }

    BOOL isRestarting = self.currentState == ThreadSafeBlockQueueRestarting;

    if (shouldReplay) {
        [self.blocks addObject:[block copy]];
    }

    // If we're currently in the process of restarting, then we don't need
    // to add it to the queue, since it will already be done so as part of the
    // restart process
    //                               isRestarting
    //
    //                          yes               no
    //                   ┌────────────────┬────────────────┐
    //                   │                │                │
    //                   │  add to array  │  add to array  │
    //               yes │ ────────────── │ ────────────── │
    //                   │       x        │     add to     │
    // shouldReplay      │                │   gcd_queue    │
    //                   ├────────────────┼────────────────┤
    //                   │                │                │
    //                   │       x        │       x        │
    //                no │ ────────────── │ ────────────── │
    //                   │     add to     │     add to     │
    //                   │   gcd_queue    │   gcd_queue    │
    //                   └────────────────┴────────────────┘
    if (!shouldReplay || !isRestarting) {
        dispatch_async(self.serialQueue, block);
    }
}

- (void)enQueueAllBlocks {
    BOOL isRestarting = self.currentState == ThreadSafeBlockQueueRestarting;

    if (isRestarting) {
        return;
    }
    
    [self startQueue];
}

- (void)enQueueAllBlocksAndRunOnComplete:(void(^)(void))onComplete {
    if (onComplete) {
        [self queueBlock:onComplete shouldReplay:NO];
    }

    [self enQueueAllBlocks];
}

#pragma mark - Restart

- (void)replay {
    BOOL alreadyRestarting = self.currentState == ThreadSafeBlockQueueRestarting;
    if (alreadyRestarting) {
        return;
    }

    [self suspendQueue];
    self.currentState = ThreadSafeBlockQueueRestarting; // override the state to restarting

    BOOL moreBlocksHaveBeenAdded = NO;
    NSUInteger count = self.blocks.count - 1;
    NSUInteger i = 0;

    do {
        while (i <= count) {
            void (^block)(void) = [self.blocks objectAtIndex:i];
            dispatch_async(self.serialQueue, block);
            i++;
        }

        moreBlocksHaveBeenAdded = count < self.blocks.count - 1;
        i = count;
        count = self.blocks.count - 1 - count;
    } while (moreBlocksHaveBeenAdded == YES);

    [self startQueue];
}


@end
