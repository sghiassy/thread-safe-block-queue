//
//  MultiThreads.m
//  thread-safe-block-queue
//
//  Created by Shaheen Ghiassy on 7/1/16.
//  Copyright © 2016 Shaheen Ghiassy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>
#import "ThreadSafeBlockQueue.h"

@interface MultiThreads : XCTestCase

@property (nonatomic, strong) ThreadSafeBlockQueue *queue;

@end

@implementation MultiThreads

- (void)setUp {
    [super setUp];
    self.queue = [[ThreadSafeBlockQueue alloc] initWithName:@"TestName"];
}

- (void)tearDown {
    self.queue = nil;
    [super tearDown];
}

- (void)testItIsThreadSafe {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.Groupon.ThreadSafeBlockQueue2", DISPATCH_QUEUE_SERIAL);
    dispatch_suspend(concurrentQueue);

    __block CGFloat count = -1.0f;
    __block CGFloat called = 0.0f;

    [self.queue queueBlock:^{
        called += 1.0f; // log the fact that we were called
        count = 0.0f;
    }];

    [self.queue queueBlock:^{
        expect(count).to.equal(0.0f);
        count += 2.2f;
    }];

    [self.queue queueBlock:^{
        expect(count).to.equal(2.2f);
    }];

    [self.queue enQueueAllBlocksAndRunOnComplete:^{
        dispatch_async(concurrentQueue, ^{
            [self.queue enQueueAllBlocksAndRunOnComplete:^{
                expect(count).to.equal(2.2f);
            }];
        });

        dispatch_async(concurrentQueue, ^{
            [self.queue enQueueAllBlocksAndRunOnComplete:^{
                expect(count).to.equal(2.2f);
            }];
        });

        dispatch_async(concurrentQueue, ^{
            expect(count).to.equal(2.2f);
            [self.queue replay];
        });

        dispatch_async(concurrentQueue, ^{
            [self.queue enQueueAllBlocksAndRunOnComplete:^{
                expect(count).to.equal(2.2f);
            }];
        });

        dispatch_async(concurrentQueue, ^{
            [self.queue enQueueAllBlocksAndRunOnComplete:^{
                expect(count).to.equal(2.2f);
                [expectation fulfill];
            }];
        });

        dispatch_resume(concurrentQueue);
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
