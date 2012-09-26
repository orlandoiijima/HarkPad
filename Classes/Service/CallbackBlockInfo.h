//
// Created by wbison on 16-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#include "ServiceResult.h"

@interface CallbackBlockInfo : NSObject

@property(nonatomic, copy) void (^success)(ServiceResult *);

@property(nonatomic, copy) void (^error)(ServiceResult *);

@property(nonatomic, strong) id view;

+ (CallbackBlockInfo *) infoWithSuccess: (void (^)(ServiceResult*))success error: (void (^)(ServiceResult*))error;

@end