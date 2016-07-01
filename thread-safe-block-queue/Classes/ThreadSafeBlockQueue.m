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

// Pointers
@property (atomic, assign) NSUInteger runPointer;
@property (atomic, assign) NSUInteger garbageCollectionPointer;

// State
@property (atomic, readwrite, assign) ThreadSafeBlockQueueStates currentState;
@property (atomic, readwrite, assign) BOOL isRunning;

@end


@implementation ThreadSafeBlockQueue

#pragma mark - Object Lifecycle

- (instancetype)init {
    return [self initWithName:@""];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];

    if (self) {
        // Setup Defaults
        _runPointer = 0;
        _garbageCollectionPointer = 0;
        _isRunning = NO;
        _blocks = [[NSMutableArray alloc] init];
        _serialQueue = dispatch_queue_create("com.Groupon.ThreadSafeBlockQueue", DISPATCH_QUEUE_SERIAL);

        // Setup Configuration
        _name = [name copy];

        [self suspendQueue];
    }

    return self;
}

#pragma mark - Start / Stop Methods

- (void)startQueue {
    [self startQueueOnComplete:nil];
}

- (void)startQueueOnComplete:(TSBlock)onComplete {
    if (onComplete) {
        [self queue:@"onComplete" shouldReplay:NO block:onComplete];
    }

    self.currentState = ThreadSafeBlockQueueStateRunning;
    [self runLoopGo];
}

- (void)suspendQueue {
    self.currentState = ThreadSafeBlockQueueStateStopped;
}

#pragma mark - Queue Methods

// Porcelain
- (void)queueBlock:(TSBlock)block {
    [self queueBlock:block shouldReplay:YES];
}

// Porcelain
- (void)queueBlock:(TSBlock)block shouldReplay:(BOOL)shouldReplay {
    [self queue:@"" shouldReplay:shouldReplay block:block];
}

- (void)queue:(NSString *)name shouldReplay:(BOOL)shouldReplay block:(TSBlock)block {
    if (block == nil) {
        return; // return early if we weren't provided a block to run
    }

    ThreadSafeBlockModel *tsBlock = [[ThreadSafeBlockModel alloc] initWithName:name shouldReplay:shouldReplay andBlock:block];
    [self.blocks addObject:tsBlock];

    [self runLoopGo];
}

#pragma mark - Restart

// This method is basically a runLoop
- (void)runLoopGo {
    /**
     * The runloop is called by many different methods (we do this to avoid creating an actual runLoop which would be too much overhead)
     * As such we need to block redundant calls
     */
    BOOL alreadyRunning = self.isRunning == YES;
    BOOL isStopped = self.currentState == ThreadSafeBlockQueueStateStopped;

    if (isStopped || alreadyRunning) {
        return;
    }

    self.isRunning = YES;

    // Iterate through the array and run the necessary blocks
    while (self.runPointer < self.blocks.count || self.currentState == ThreadSafeBlockQueueStateStopped) {
        ThreadSafeBlockModel *tsBlock = (ThreadSafeBlockModel *)[self.blocks objectAtIndex:self.runPointer];
        if (tsBlock.block != nil) {
            dispatch_async(self.serialQueue, tsBlock.block);
        }
        self.runPointer += 1;
    }

    // After we have run all the blocks, run garbage collection up the the point of the runPointer (i.e: blocks that were run)
    while (self.garbageCollectionPointer < self.runPointer) {
        ThreadSafeBlockModel *tsBlock = (ThreadSafeBlockModel *)[self.blocks objectAtIndex:self.garbageCollectionPointer];

        if (tsBlock.shouldReplay == NO) {
            [self.blocks removeObjectAtIndex:self.garbageCollectionPointer];
            self.runPointer -= 1;
        } else {
            self.garbageCollectionPointer += 1;
        }
    }

    self.isRunning = NO;
}

- (void)replay {
    self.currentState = ThreadSafeBlockQueueStateStopped; // Stop the run loop if its going

    // Reset the pointers back to the start
    self.runPointer = 0;
    self.garbageCollectionPointer = 0;

    self.currentState = ThreadSafeBlockQueueStateRunning; // Allow the run loop to continue again

    // Go!
    [self runLoopGo];
}

#pragma mark - Debugging

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"Queue:%@", self.name];
    for (NSUInteger i = 0; i < self.blocks.count; i++) {
        ThreadSafeBlockModel *tsBlock = (ThreadSafeBlockModel *)[self.blocks objectAtIndex:i];
        description = [NSString stringWithFormat:@"%@\nBlock:%@", description, tsBlock.name];
    }
    return description;
}

@end
