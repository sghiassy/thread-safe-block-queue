//
//  BasicOperations.m
//  thread-safe-block-queue
//
//  Created by Shaheen Ghiassy on 7/1/16.
//  Copyright © 2016 Shaheen Ghiassy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>
#import "ThreadSafeBlockQueue.h"

@interface BasicOperations : XCTestCase

@property (nonatomic, strong) ThreadSafeBlockQueue *queue;

@end

@implementation BasicOperations

- (void)setUp {
    [super setUp];
    self.queue = [[ThreadSafeBlockQueue alloc] initWithName:@"TestName"];
}

- (void)tearDown {
    self.queue = nil;
    [super tearDown];
}

- (void)testItCanBeInstantiated {
    expect(self.queue).willNot.beNil();
}

- (void)testItCanRunBlocks {
    __block BOOL blockWasRun = NO;

    [self.queue queueBlock:^{
        blockWasRun = YES;
    }];

    expect(blockWasRun).to.equal(NO);

    [self.queue queueBlock:^{
        expect(blockWasRun).to.equal(YES);
    }];

    [self.queue enQueueAllBlocksAndRunOnComplete:^{
        expect(blockWasRun).to.equal(YES);
    }];
}

- (void)testMessagingStartQueueMultipleTimesWillNotCrash {
    __block BOOL blockWasRun = NO;

    [self.queue queueBlock:^{
        blockWasRun = YES;
    }];

    expect(blockWasRun).to.equal(NO);
    [self.queue enQueueAllBlocks];
    [self.queue enQueueAllBlocks];
    [self.queue enQueueAllBlocks];
    [self.queue enQueueAllBlocks];
}

- (void)tesItWillRunBlocksInOrder {
    __block CGFloat count = 0.0f;

    [self.queue queueBlock:^{
        expect(count).to.equal(0.0f);
        count += 2.2f;
    }];

    [self.queue queueBlock:^{
        expect(count).to.equal(2.2f);
        count += 3.3f;
    }];

    [self.queue queueBlock:^{
        expect(count).to.equal(5.5f);
        count += 4.4f;
    }];

    [self.queue queueBlock:^{
        expect(count).to.equal(9.9f);
        count += 5.5f;
    }];

    [self.queue queueBlock:^{
        expect(count).to.equal(15.4f);
    }];

    [self.queue enQueueAllBlocks];
}

- (void)testItWillRunBlocksImmediatlyWhenTheQueueIsInRunMode {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];

    __block CGFloat count = 0.0f;

    [self.queue queueBlock:^{
        expect(count).to.equal(0.0f);
        count += 2.2f;
    }];

    [self.queue queueBlock:^{
        expect(count).to.equal(2.2f);
        count += 3.3f;
    }];

    [self.queue enQueueAllBlocks];

    [self.queue queueBlock:^{
        expect(count).to.equal(5.5f);
        count += 4.4f;
    }];

    [self.queue queueBlock:^{
        expect(count).to.equal(9.9f);
        count += 5.5f;
    }];

    [self.queue queueBlock:^{
        expect(count).to.equal(15.4f);

        [expectation fulfill];
    }];

    [self.queue enQueueAllBlocks];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testItCanHaveBlocksThatAreRunOnlyOnce {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];

    // Async example blocks need to invoke done() callback.
    __block CGFloat count = -1.0f;

    __block CGFloat called1 = 0.0f;
    __block CGFloat called2 = 0.0f;
    __block CGFloat called3 = 0.0f;
    __block CGFloat called4 = 0.0f;
    __block CGFloat called5 = 0.0f;
    __block CGFloat called6 = 0.0f;

    [self.queue queueBlock:^{
        called1 += 1.0f; // log the fact that we were called
        count = 0.0f;
    }];

    [self.queue queueBlock:^{
        called2 += 1;
        expect(count).to.equal(0.0f);
        count += 2.2f;
    }];

    [self.queue queueBlock:^{
        called3 += 1;
        expect(count).to.equal(2.2f);
        count += 3.3f;
    }];

    [self.queue queueBlock:^{
        called4 += 1;
        expect(count).to.equal(5.5f);
        count += 4.4f;
    }];

    [self.queue queueBlock:^{
        called5 += 1;
        expect(count).to.equal(9.9f);
        count += 5.5f;
    }];

    [self.queue queueBlock:^{
        called6 += 1;
        expect(count).to.equal(15.4f);
    }];

    [self.queue enQueueAllBlocksAndRunOnComplete:^{
        expect(called1).to.equal(1);
        expect(called2).to.equal(1);
        expect(called3).to.equal(1);
        expect(called4).to.equal(1);
        expect(called5).to.equal(1);
        expect(called6).to.equal(1);

        expect(count).to.equal(15.4f);
        NSLog(@"Replaying 1");
        [self.queue replay];
        NSLog(@"Replaying 2");
        [self.queue replay];

        NSLog(@"queueBlock 1");
        [self.queue queueBlock:^{
            called1 += 0.1f;
        } shouldReplay:NO];

        NSLog(@"Replaying 3");
        [self.queue replay];

        NSLog(@"Replaying 4");
        [self.queue replay];

        NSLog(@"Replaying 5");
        [self.queue replay];

        NSLog(@"queueBlock 2");
        [self.queue queueBlock:^{
            expect(called1).to.equal(6.1f); // Has the single run block be run multiple times the decimal would be off here
            
            expect(count).to.equal(15.4f);
            count += 6.6f;
            expect(count).to.equal(22.0f);
        }];

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testTheQueueCanBeSuspended {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];

    __block CGFloat count = 0.0f;

    [self.queue queueBlock:^{
        expect(count).to.equal(0.0f);
        count += 2.2f;
    }];

    [self.queue queueBlock:^{
        expect(count).to.equal(2.2f);
        count += 3.3f;
    }];

    [self.queue enQueueAllBlocks];

    [self.queue queueBlock:^{
        expect(count).to.equal(5.5f);
        count += 4.4f;
    }];

    [self.queue enQueueAllBlocksAndRunOnComplete:^{
        [self.queue suspendQueue];
        [self.queue queueBlock:^{
            expect(count).to.equal(9.9f); // this block shouldn't get run
            count += 5.5f; // this shouldn't get run
        }];
        [self.queue queueBlock:^{
            expect(count).to.equal(9.9f); // this block shouldn't get run
        }];

        // Give the test 1 second to make sure the blocks aren't run
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            expect(count).to.equal(9.9f);
            expect(count).toNot.equal(15.4f);
            [expectation fulfill];
        });
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
