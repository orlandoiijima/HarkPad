//
// Created by wbison on 11-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface Credentials : NSObject
@property(nonatomic, copy) NSString *password;
@property(nonatomic, copy) NSString *email;
@property(nonatomic, copy) NSString *pincode;

+ (Credentials *)credentialsWithEmail:(NSString *)email password:(NSString *)password pincode:(NSString *)pincode;

@end