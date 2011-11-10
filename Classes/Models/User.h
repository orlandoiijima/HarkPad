//
//  Created by wbison on 10-11-11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface User : NSObject {
    NSString *name;
    int id;
}

@property (retain) NSString *name;
@property int id;

+ (NSMutableArray *) usersFromJson:(NSMutableArray *)usersJson;
+ (User *) userFromJsonDictionary: (NSDictionary *)jsonDictionary;
+ (User *) userNull;

- (bool) isNullUser;

@end