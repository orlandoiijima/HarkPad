//
//  Created by wbison on 10-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface User : NSObject {
}

typedef enum Role {RoleStandard, RoleManager, RoleBackOffice, RoleAdmin} Role ;

@property int id;
@property(nonatomic, strong) NSString * pinCode;
@property(nonatomic) int role;

@property(nonatomic) int locationId;

@property(nonatomic, strong) NSString *firstName;

@property(nonatomic, strong) NSString *surName;

@property(nonatomic, copy) NSString *email;

@property(nonatomic, copy) NSString *password;

+ (User *) userFromJsonDictionary: (NSDictionary *)jsonDictionary;
+ (User *) userNull;

- (bool) isNullUser;

@end