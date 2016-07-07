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
@property (nonatomic, strong) NSMutableArray *blocksToReplay;

// Threads
@property (nonatomic, strong) NSOperationQueue *queue; // the queue that all operations are run on inside this datastructure

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
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
        _blocksToReplay = [[NSMutableArray alloc] init];

        [self suspendQueue];
    }

    return self;
}

- (void)dealloc {
    [_queue cancelAllOperations];
    _queue = nil;
}

#pragma mark - Start / Stop Methods

- (void)startQueue {
    self.queue.suspended = NO;
}

- (void)suspendQueue {
    self.queue.suspended = YES;
}

- (ThreadSafeBlockQueueStates)currentState {
    if (self.queue.isSuspended == YES) {
        return ThreadSafeBlockQueueStopped;
    } else {
        return ThreadSafeBlockQueueRunning;
    }
}

#pragma mark - Queue Methods

// Porcelain
- (void)queueBlock:(TSBlock)block {
    [self queueBlock:block shouldReplay:YES];
}

// Porcelain
- (void)queueBlock:(TSBlock)block shouldReplay:(BOOL)shouldReplay {
    [self queueBlock:@"" shouldReplay:shouldReplay withBlock:block];
}

- (void)queueBlock:(NSString *)name shouldReplay:(BOOL)shouldReplay withBlock:(TSBlock)block {
    if (block == nil) {
        return; // return early if we weren't provided a block to run
    }

    BOOL isRestarting = self.currentState == ThreadSafeBlockQueueRestarting;

    ThreadSafeBlockModel *tsBlock = [[ThreadSafeBlockModel alloc] initWithName:name shouldReplay:shouldReplay andBlock:block];

    if (shouldReplay) {
        [self.blocksToReplay addObject:tsBlock];
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
        [self.queue addOperation:tsBlock.operation];
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

    BOOL moreBlocksHaveBeenAdded = NO;
    NSInteger count = self.blocksToReplay.count - 1;
    NSInteger i = 0;

    do {
        while (i <= count) {
            ThreadSafeBlockModel *tsBlock = (ThreadSafeBlockModel *)[self.blocksToReplay objectAtIndex:i];
            [self.queue addOperation:tsBlock.operation];
            i++;
        }

        moreBlocksHaveBeenAdded = count < self.blocksToReplay.count - 1;
        i = count;
        count = self.blocksToReplay.count - 1 - count;
    } while (moreBlocksHaveBeenAdded == YES);

    [self startQueue];
}

#pragma mark - Debugging

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"Queue:%@", self.name];

    for (NSUInteger i = 0; i < self.blocksToReplay.count; i++) {
        ThreadSafeBlockModel *tsBlock = (ThreadSafeBlockModel *)[self.blocksToReplay objectAtIndex:i];
        description = [NSString stringWithFormat:@"%@\nBlock:%@", description, tsBlock.name];
    }

    return description;
}


@end
