//
// Created by wbison on 09-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface Signon : NSObject

@property (retain) NSString *tenant;
@property (retain) NSString *email;
@property (retain) NSString *password;
@property (retain) NSString *firstName;
@property (retain) NSString *surName;
@property (retain) NSString *pinCode;
@property (retain) NSString *location;
@property (retain) NSString *ip;

- (NSMutableDictionary *)toDictionary;


@end