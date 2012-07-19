//
// Created by wbison on 19-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface CallbackInfo : NSObject

@property (retain) NSInvocation *invocation;
@property (assign) id (^converter)(NSDictionary *);

+ (CallbackInfo *)infoWithDelegate:(id)delegate callback: (SEL) callback converter:(id (^)(NSDictionary *))converter;
@end