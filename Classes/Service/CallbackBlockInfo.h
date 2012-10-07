//
// Created by wbison on 16-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#include "ServiceResult.h"

@class ProgressInfo;

@interface CallbackBlockInfo : NSObject

@property(nonatomic, copy) void (^success)(ServiceResult *);

@property(nonatomic, copy) void (^error)(ServiceResult *);

@property(nonatomic, strong) id view;

@property(nonatomic, strong) ProgressInfo *progressInfo;

@property(nonatomic) BOOL isAdminRequired;

+ (CallbackBlockInfo *)infoWithSuccess:(void (^)(ServiceResult *))success error:(void (^)(ServiceResult *))error progressInfo:(ProgressInfo *)info;

@end