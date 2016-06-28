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

describe(@"these will pass", ^{

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

        [queue enQueueAllBlocksAndRunOnComplete:^{
            expect(blockWasRun).to.equal(YES);
        }];
    });

    it(@"message enQueue will not crash the data structure", ^{
        __block BOOL blockWasRun = NO;

        [queue queueBlock:^{
            blockWasRun = YES;
        }];

        expect(blockWasRun).to.equal(NO);
        [queue enQueueAllBlocksAndRun];
        [queue enQueueAllBlocksAndRun];
        [queue enQueueAllBlocksAndRun];
        [queue enQueueAllBlocksAndRun];
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

        [queue enQueueAllBlocksAndRun];
    });

    it(@"will run blocks immediatly after the queue has been enqueued", ^{
        __block CGFloat count = 0.0f;

        [queue queueBlock:^{
            expect(count).to.equal(0.0f);
            count += 2.2f;
        }];

        [queue queueBlock:^{
            expect(count).to.equal(2.2f);
            count += 3.3f;
        }];

        [queue enQueueAllBlocksAndRun];

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

    });
});

SpecEnd

