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

typedef enum Role {RoleStandard, RoleManager, RoleBackOffice, RoleAdmin} Role ;

@property (retain) NSString *name;
@property int id;
@property(nonatomic, strong) id pin;
@property(nonatomic) int role;

@property(nonatomic) int locationId;

+ (User *) userFromJsonDictionary: (NSDictionary *)jsonDictionary;
+ (User *) userNull;

- (bool) isNullUser;

@end