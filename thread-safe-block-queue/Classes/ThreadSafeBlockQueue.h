//
//  ThreadSafeBlockQueue.h
//  Pods
//
//  Created by Shaheen Ghiassy on 6/27/16.
//
//

#import <Foundation/Foundation.h>

typedef void (^TSBlock)(void);

typedef NS_ENUM(NSUInteger, ThreadSafeBlockQueueStates) {
    ThreadSafeBlockQueueStateStopped,
    ThreadSafeBlockQueueStateRunning,
};

/**
 *  This class is an opinionted thread-safe FIFO queue designed for blocks.
 *  It takes in blocks and queues them until it is messaged to purge and run
 *  all blocks. After the purge event, this data-structure will no longer
 *  queue future blocks and will instead run any block given to immediatly.
 */
@interface ThreadSafeBlockQueue : NSObject

@property (atomic, readonly, assign) ThreadSafeBlockQueueStates currentState;

/**
 * Designated Initailzer
 * @param name is used for debugging
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  Queue a block to be run later. If the data structure has already
 *  been flipped to runImmedidatly state, then the block will be
 *  executed immediatly
 *
 *  @param block Block to be run
 */
- (void)queueBlock:(TSBlock)block;
- (void)queueBlock:(TSBlock)block shouldReplay:(BOOL)shouldReplay;
- (void)queue:(NSString *)name shouldReplay:(BOOL)shouldReplay block:(TSBlock)block;

/**
 *  Message the data-structure to run all blocks that are currently in the queue.
 *  This message also transitions the data-structure to run immediatly mode, whereby
 *  any future blocks will no longer be queued.
 */
- (void)startQueue;
- (void)startQueueOnComplete:(TSBlock)onComplete;

/**
 *  Message the data-structure to replay all blocks
 */
- (void)replay;

@end
