//
// Created by wbison on 19-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CallbackInfo.h"


@implementation CallbackInfo

@synthesize converter = _converter;
@synthesize invocation = _invocation;


+ (CallbackInfo *)infoWithDelegate:(id)delegate callback: (SEL) callback converter:(id (^)(NSDictionary *))converter {
    CallbackInfo *info = [[CallbackInfo alloc] init];
    info.converter = converter;
    NSMethodSignature *sig = [delegate methodSignatureForSelector:callback];
    info.invocation = [NSInvocation invocationWithMethodSignature:sig];
    [info.invocation setTarget:delegate];
    [info.invocation setSelector:callback];
    return info;
}

@end