//
//  Created by wbison on 04-03-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "EntityState.h"


@interface DTO : NSObject {
    EntityState entityState;
    int id;
}

@property (nonatomic) EntityState entityState;
@property int id;

- (id)initWithJson:(NSDictionary *)jsonDictionary;
- (NSMutableDictionary *)toDictionary;

@end