//
//  Created by wbison on 10-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "User.h"


@implementation User

@synthesize name, id;


+ (User *) userNull
{
    User *user = [[User alloc] init];
    user.name = @"";
    user.id = -1;
    return user;
}

+ (User *) userFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    User *user = [[User alloc] init];
    user.name = [jsonDictionary objectForKey:@"name"];
    user.id = [[jsonDictionary objectForKey:@"id"] intValue];
    return user;
}

+ (NSMutableArray *) usersFromJson:(NSMutableArray *)usersJson
{
    NSMutableArray *users = [[NSMutableArray alloc] init];
    for(NSDictionary *userDic in usersJson)
    {
        User *user = [User userFromJsonDictionary: userDic];
        [users addObject:user];
    }
    return users;
}

- (bool) isNullUser
{
    return id == -1;
}

@end