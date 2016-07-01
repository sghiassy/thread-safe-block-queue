//
//  thread-safe-block-queueTests.m
//  thread-safe-block-queueTests
//
//  Created by Shaheen Ghiassy on 06/27/2016.
//  Copyright (c) 2016 Shaheen Ghiassy. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "ThreadSafeBlockQueue.h"


SpecBegin(InitialSpecs)

describe(@"ThreadSafeBlockQueue", ^{

    __block ThreadSafeBlockQueue *queue;

    beforeEach(^{
        queue = [[ThreadSafeBlockQueue alloc] init];
    });

    afterEach(^{
        queue = nil;
    });

    it(@"can instantiate the object", ^{
        expect(queue).willNot.beNil();
    });

    it(@"can run blocks", ^{
        __block BOOL blockWasRun = NO;

        [queue queueBlock:^{
            blockWasRun = YES;
        }];

        expect(blockWasRun).to.equal(NO);

        [queue queueBlock:^{
            expect(blockWasRun).to.equal(YES);
        }];

        [queue startQueueOnComplete:^{
            expect(blockWasRun).to.equal(YES);
        }];
    });

    it(@"message enQueue will not crash the data structure", ^{
        __block BOOL blockWasRun = NO;

        [queue queueBlock:^{
            blockWasRun = YES;
        }];

        expect(blockWasRun).to.equal(NO);
        [queue startQueue];
        [queue startQueue];
        [queue startQueue];
        [queue startQueue];
    });

    it(@"will run the blocks in order", ^{
        __block CGFloat count = 0.0f;

        [queue queueBlock:^{
            expect(count).to.equal(0.0f);
            count += 2.2f;
        }];

        [queue queueBlock:^{
            expect(count).to.equal(2.2f);
            count += 3.3f;
        }];

        [queue queueBlock:^{
            expect(count).to.equal(5.5f);
            count += 4.4f;
        }];

        [queue queueBlock:^{
            expect(count).to.equal(9.9f);
            count += 5.5f;
        }];

        [queue queueBlock:^{
            expect(count).to.equal(15.4f);
        }];

        [queue startQueue];
    });

    it(@"will run blocks immediatly after the queue has been enqueued", ^{
        waitUntil(^(DoneCallback done) {
            __block CGFloat count = 0.0f;

            [queue queueBlock:^{
                expect(count).to.equal(0.0f);
                count += 2.2f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(2.2f);
                count += 3.3f;
            }];

            [queue startQueue];

            [queue queueBlock:^{
                expect(count).to.equal(5.5f);
                count += 4.4f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(9.9f);
                count += 5.5f;
            }];
            
            [queue queueBlock:^{
                expect(count).to.equal(15.4f);
                done();
            }];

            [queue startQueue];
        });
    });

    it(@"can replay the order of the queue", ^{
        waitUntil(^(DoneCallback done) {
            __block CGFloat count = -1.0f;
            __block NSUInteger called = 0;

            [queue queueBlock:^{
                called++; // log the fact that we were called
                count = 0.0f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(0.0f);
                count += 2.2f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(2.2f);
                count += 3.3f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(5.5f);
                count += 4.4f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(9.9f);
                count += 5.5f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(15.4f);
            }];

            expect(queue.currentState).to.equal(ThreadSafeBlockQueueStateStopped);

            [queue startQueueOnComplete:^{
                expect(called).to.equal(1);
                expect(count).to.equal(15.4f);
                expect(queue.currentState).to.equal(ThreadSafeBlockQueueStateRunning);
                [queue replay];
                [queue queueBlock:^{
                    expect(count).to.equal(15.4f);
                    count += 6.6f;
                    expect(count).to.equal(22.0f);
                    
                    expect(called).to.equal(2);

                    done();
                }];
            }];
        });

    });

    it(@"calling replay multiple times is fine", ^{

        waitUntil(^(DoneCallback done) {
            // Async example blocks need to invoke done() callback.
            __block CGFloat count = -1.0f;
            __block NSUInteger called = 0;

            [queue queueBlock:^{
                called++; // log the fact that we were called
                count = 0.0f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(0.0f);
                count += 2.2f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(2.2f);
                count += 3.3f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(5.5f);
                count += 4.4f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(9.9f);
                count += 5.5f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(15.4f);
            }];

            [queue startQueueOnComplete:^{
                expect(called).to.equal(1);
                expect(count).to.equal(15.4f);
                [queue replay];
                [queue replay];
                [queue replay];
                [queue replay];
                [queue replay];
                [queue queueBlock:^{
                    expect(count).to.equal(15.4f);
                    count += 6.6f;
                    expect(count).to.equal(22.0f);
                    
                    expect(called).to.equal(6);
                }];
                done();
            }];
        });

    });

    it(@"can take a block that is run only once. Regardless of replay being called on it", ^{

        waitUntil(^(DoneCallback done) {
            // Async example blocks need to invoke done() callback.
            __block CGFloat count = -1.0f;
            __block CGFloat called = 0.0f;

            [queue queueBlock:^{
                called += 1.0f; // log the fact that we were called
                count = 0.0f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(0.0f);
                count += 2.2f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(2.2f);
                count += 3.3f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(5.5f);
                count += 4.4f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(9.9f);
                count += 5.5f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(15.4f);
            }];

            [queue startQueueOnComplete:^{
                expect(called).to.equal(1);
                expect(count).to.equal(15.4f);
                [queue replay];
                [queue replay];
                [queue queueBlock:^{
                    called += 0.1f;
                } shouldReplay:NO];
                [queue replay];
                [queue replay];
                [queue replay];
                [queue queueBlock:^{
                    expect(count).to.equal(15.4f);
                    count += 6.6f;
                    expect(count).to.equal(22.0f);

                    expect(called).to.equal(6.1f); // Has the single run block be run multiple times the decimal would be off here
                }];
                done();
            }];
        });
    });

    it(@"can handle multi-threads during restart", ^{
        waitUntil(^(DoneCallback done) {
            dispatch_queue_t concurrentQueue = dispatch_queue_create("com.Groupon.ThreadSafeBlockQueue2", DISPATCH_QUEUE_CONCURRENT);
            dispatch_suspend(concurrentQueue);

            __block CGFloat count = -1.0f;
            __block CGFloat called = 0.0f;

            [queue queueBlock:^{
                called += 1.0f; // log the fact that we were called
                count = 0.0f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(0.0f);
                count += 2.2f;
            }];

            [queue queueBlock:^{
                expect(count).to.equal(2.2f);
            }];

            [queue startQueueOnComplete:^{
                dispatch_async(concurrentQueue, ^{
                    [queue startQueueOnComplete:^{
                        expect(count).to.equal(2.2f);
                        done();
                    }];
                });

                dispatch_async(concurrentQueue, ^{
                    [queue startQueueOnComplete:^{
                        expect(count).to.equal(2.2f);
                        done();
                    }];
                });
                
                dispatch_async(concurrentQueue, ^{
                    expect(count).to.equal(2.2f);
                    [queue replay];
                });

                dispatch_async(concurrentQueue, ^{
                    [queue startQueueOnComplete:^{
                        expect(count).to.equal(2.2f);
                    }];
                });

                dispatch_async(concurrentQueue, ^{
                    [queue startQueueOnComplete:^{
                        expect(count).to.equal(2.2f);
                        done();
                    }];
                });

                dispatch_resume(concurrentQueue);
            }];
        });
    });
});

SpecEnd

