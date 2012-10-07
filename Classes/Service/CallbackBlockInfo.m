//
// Created by wbison on 16-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CallbackBlockInfo.h"
#import "ServiceResult.h"
#import "ProgressInfo.h"


@implementation CallbackBlockInfo {

}
@synthesize success = _success;
@synthesize error = _error;
@synthesize view = _view;
@synthesize progressInfo = _progressInfo;
@synthesize isAdminRequired = _isAdminRequired;


+ (CallbackBlockInfo *)infoWithSuccess:(void (^)(ServiceResult *))success error:(void (^)(ServiceResult *))error progressInfo:(ProgressInfo *)progressInfo {
    CallbackBlockInfo *info = [[CallbackBlockInfo alloc] init];
    info.success = success;
    info.error = error;
    info.progressInfo = progressInfo;
    info.isAdminRequired = NO;
    return info;
}
@end