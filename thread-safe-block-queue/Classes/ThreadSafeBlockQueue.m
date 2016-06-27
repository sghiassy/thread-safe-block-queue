//
//  ThreadSafeBlockQueue.m
//  Pods
//
//  Created by Shaheen Ghiassy on 6/27/16.
//
//

#import "ThreadSafeBlockQueue.h"

@interface ThreadSafeBlockQueue ()

@property (atomic, strong) dispatch_queue_t serialQueue; // the queue that all operations are run on inside this datastructure
@property (atomic, assign) BOOL isSuspended;

@end


@implementation ThreadSafeBlockQueue

#pragma mark - Object Lifecycle

- (instancetype)init {
    self = [super init];

    if (self) {
        // Create and suspend the queue
        _serialQueue = dispatch_queue_create("com.Groupon.ThreadSafeBlockQueue", DISPATCH_QUEUE_SERIAL);
        [self suspendQueue];
    }

    return self;
}

- (void)dealloc {
    if (self.isSuspended == YES) {
        // You can't dealloc a suspended queue: http://stackoverflow.com/a/9572316/1179897
        [self startQueue];
    }

    _serialQueue = nil;
}

#pragma mark - Start / Stop Methods

- (void)startQueue {
    dispatch_resume(_serialQueue);
    _isSuspended = NO;
}

- (void)suspendQueue {
    dispatch_suspend(_serialQueue);
    _isSuspended = YES;
}

#pragma mark - Queue Methods

- (void)queueBlock:(void(^)(void))block {
    if (block == nil) {
        return; // return early if we weren't provided a block to run
    }

    dispatch_async(self.serialQueue, block);
}

- (void)enQueueAllBlocksAndRun {
    [self startQueue];
}


@end
