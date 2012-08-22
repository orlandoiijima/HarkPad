//
// Created by wbison on 11-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#import "Credentials.h"

@interface CredentialsAlertView : NSObject

@property(nonatomic, copy) void (^afterDone)(Credentials *);

@property(nonatomic, copy) NSString *pincode;

+ (CredentialsAlertView *) viewWithPincode:(NSString *)pin afterDone:(void (^)(Credentials *))afterDone;

@end