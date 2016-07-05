//
//  ThreadSafeBlockModel.h
//  Pods
//
//  Created by Shaheen Ghiassy on 6/30/16.
//
//

#import <Foundation/Foundation.h>

typedef void (^TSBlock)(void);

@interface ThreadSafeBlockModel : NSObject

- (instancetype)initWithName:(NSString *)name shouldReplay:(BOOL)shouldReplay andBlock:(TSBlock)block;

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, assign) BOOL shouldReplay;
//@property (nonatomic, readonly, copy) TSBlock block;
@property (nonatomic, readonly, copy) NSBlockOperation *operation;

@end
