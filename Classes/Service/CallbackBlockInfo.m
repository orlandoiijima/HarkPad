//
// Created by wbison on 16-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CallbackBlockInfo.h"
#import "ServiceResult.h"


@implementation CallbackBlockInfo {

}
@synthesize success = _success;
@synthesize error = _error;
@synthesize view = _view;


+ (CallbackBlockInfo *) infoWithSuccess: (void (^)(ServiceResult*))success error:(void (^)(ServiceResult*))error {
    CallbackBlockInfo *info = [[CallbackBlockInfo alloc] init];
    info.success = success;
    info.error = error;
    return info;
}
@end