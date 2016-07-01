//
//  DescriptionTests.m
//  thread-safe-block-queue
//
//  Created by Shaheen Ghiassy on 7/1/16.
//  Copyright © 2016 Shaheen Ghiassy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>
#import "ThreadSafeBlockQueue.h"

@interface DescriptionTests : XCTestCase

@property (nonatomic, strong) ThreadSafeBlockQueue *queue;

@end

@implementation DescriptionTests

//- (void)setUp {
//    [super setUp];
//    self.queue = [[ThreadSafeBlockQueue alloc] initWithName:@"TestName"];
//}
//
//- (void)tearDown {
//    self.queue = nil;
//    [super tearDown];
//}
//
//- (void)testIsWorking {
//    expect(self.queue).willNot.beNil();
//}
//
//- (void)testEachQueueCanBeNamed {
//    expect(self.queue.name).to.equal(@"TestName");
//}
//
//- (void)testItCanOutputAFullDescription {
//    [self.queue queue:@"test1" shouldReplay:YES block:^{
//        // do something
//    }];
//
//    [self.queue queue:@"test2" shouldReplay:YES block:^{
//        // do something
//    }];
//
//    [self.queue queue:@"test3" shouldReplay:YES block:^{
//        // do something
//    }];
//
//    NSString *description = [self.queue description];
//    NSString *expectedDescription = @"Queue:TestName\nBlock:test1\nBlock:test2\nBlock:test3";
//
//    expect(description).to.equal(expectedDescription);
//}

@end
