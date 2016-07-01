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

- (void)itCanBeInstantiated {
    expect(self.queue).willNot.beNil();
}

- (void)itCanRunBlocks {
    __block BOOL blockWasRun = NO;

    [self.queue queueBlock:^{
        blockWasRun = YES;
    }];

    expect(blockWasRun).to.equal(NO);

    [self.queue queueBlock:^{
        expect(blockWasRun).to.equal(YES);
    }];

    [self.queue startQueueOnComplete:^{
        expect(blockWasRun).to.equal(YES);
    }];
}

- (void)messageStartQueueMultipleTimesWillNotCrash {
    __block BOOL blockWasRun = NO;

    [self.queue queueBlock:^{
        blockWasRun = YES;
    }];

    expect(blockWasRun).to.equal(NO);
    [self.queue startQueue];
    [self.queue startQueue];
    [self.queue startQueue];
    [self.queue startQueue];
}

- (void)ttWillRunBlocksInOrder {
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

    [self.queue startQueue];
}

- (void)itWillRunBlocksImmediatlyWhenTheQueueIsInRunMode {
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

    [self.queue startQueue];

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

    [self.queue startQueue];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)titCanHaveBlocksThatAreRunOnlyOnce {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];

    // Async example blocks need to invoke done() callback.
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

    [self.queue startQueueOnComplete:^{
        expect(called).to.equal(1);
        expect(count).to.equal(15.4f);
        [self.queue replay];
        [self.queue replay];
        [self.queue queueBlock:^{
            called += 0.1f;
        } shouldReplay:NO];
        [self.queue replay];
        [self.queue replay];
        [self.queue replay];
        [self.queue queueBlock:^{
            expect(count).to.equal(15.4f);
            count += 6.6f;
            expect(count).to.equal(22.0f);

            expect(called).to.equal(6.1f); // Has the single run block be run multiple times the decimal would be off here
        }];

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
