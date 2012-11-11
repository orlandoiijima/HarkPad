//
//  Created by wbison on 10-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "User.h"


@implementation User

@synthesize name, id;
@synthesize pin = _pin;
@synthesize role = _role;
@synthesize locationId = _locationId;

+ (User *) userNull
{
    User *user = [[User alloc] init];
    user.name = @"";
    user.pin = @"";
    user.role = RoleStandard;
    user.id = -1;
    user.locationId = nil;
    return user;
}

+ (User *) userFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    User *user = [[User alloc] init];
    user.name = [jsonDictionary objectForKey:@"name"];
    user.id = [[jsonDictionary objectForKey:@"id"] intValue];
    user.pin = [jsonDictionary objectForKey:@"pin"];
    user.locationId = nil;
    user.locationId = [jsonDictionary objectForKey:@"locationId"];
    user.role = (Role) [[jsonDictionary objectForKey:@"role"] intValue];
    return user;
}

- (bool) isNullUser
{
    return id == -1;
}

@end