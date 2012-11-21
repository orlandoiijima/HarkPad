//
//  Created by wbison on 10-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "User.h"


@implementation User

+ (User *) userNull
{
    User *user = [[User alloc] init];
    user.firstName = @"";
    user.surName = @"";
    user.pinCode = @"";
    user.role = RoleStandard;
    user.id = -1;
    user.locationId = -1;
    return user;
}

+ (User *) userFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    User *user = [[User alloc] init];
    user.firstName = [jsonDictionary objectForKey:@"firstName"];
    user.surName = [jsonDictionary objectForKey:@"surName"];
    user.id = [[jsonDictionary objectForKey:@"id"] intValue];
    user.pinCode = [jsonDictionary objectForKey:@"pinCode"];
    user.locationId = [[jsonDictionary objectForKey:@"locationId"] intValue];
    user.role = (Role) [[jsonDictionary objectForKey:@"role"] intValue];
    return user;
}

- (bool) isNullUser
{
    return _id == -1;
}

@end