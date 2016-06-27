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
    
    it(@"can do maths", ^{
        expect(1).beLessThan(23);
    });
    
    it(@"can read", ^{
        expect(@"team").toNot.contain(@"I");
    });
    
    it(@"will wait and succeed", ^{
        waitUntil(^(DoneCallback done) {
            done();
        });
    });

    it(@"can instantiate the object", ^{
        ThreadSafeBlockQueue *queue = [[ThreadSafeBlockQueue alloc] init];
        expect(queue).willNot.beNil();
    });
});

SpecEnd

