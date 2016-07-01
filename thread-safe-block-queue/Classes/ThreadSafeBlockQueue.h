//
//  ThreadSafeBlockQueue.h
//  Pods
//
//  Created by Shaheen Ghiassy on 6/27/16.
//
//

#import <Foundation/Foundation.h>

typedef int (^RNCBlock)(void);

typedef NS_ENUM(NSUInteger, ThreadSafeBlockQueueStates) {
    ThreadSafeBlockQueueStopped,
    ThreadSafeBlockQueueRunning,
    ThreadSafeBlockQueueRestarting
};

/**
 *  This class is an opinionted thread-safe FIFO queue designed for blocks.
 *  It takes in blocks and queues them until it is messaged to purge and run
 *  all blocks. After the purge event, this data-structure will no longer
 *  queue future blocks and will instead run any block given to immediatly.
 */
@interface ThreadSafeBlockQueue : NSObject

@property (nonatomic, readonly, copy) NSString *name;
@property (atomic, readonly, assign) ThreadSafeBlockQueueStates currentState;

- (instancetype)initWithName:(NSString *)name;

/**
 *  Queue a block to be run later. If the data structure has already
 *  been flipped to runImmedidatly state, then the block will be
 *  executed immediatly
 *
 *  @param block Block to be run
 */
- (void)queueBlock:(void(^)(void))block;
- (void)queueBlock:(void(^)(void))block shouldReplay:(BOOL)shouldReplay;

/**
 *  Message the data-structure to run all blocks that are currently in the queue.
 *  This message also transitions the data-structure to runImmediatly mode, whereby
 *  any future blocks will no longer be queued.
 */
- (void)enQueueAllBlocks;
- (void)enQueueAllBlocksAndRunOnComplete:(void(^)(void))onComplete;

/**
 *  Message the data-structure to replay all blocks
 */
- (void)replay;

@end
