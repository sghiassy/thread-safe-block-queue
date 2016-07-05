//
//  ThreadSafeBlockModel.m
//  Pods
//
//  Created by Shaheen Ghiassy on 6/30/16.
//
//

#import "ThreadSafeBlockModel.h"

@interface ThreadSafeBlockModel ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readwrite, assign) BOOL shouldReplay;
@property (nonatomic, readwrite, copy) TSBlock block;

@end

@implementation ThreadSafeBlockModel

#pragma mark - Object Lifecycle

- (instancetype)initWithBlock:(TSBlock)block {
    return [self initWithName:@"" shouldReplay:YES andBlock:block];
}

- (instancetype)initWithName:(NSString *)name shouldReplay:(BOOL)shouldReplay andBlock:(TSBlock)block {
    self = [super init];

    if (self) {
        _name = [name copy];
        _shouldReplay = shouldReplay;
        _block = [block copy];
    }

    return self;
}

- (NSBlockOperation *)operation {
    return [NSBlockOperation blockOperationWithBlock:self.block];
}

@end
