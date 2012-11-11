//
//  Created by wbison on 04-03-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "EntityState.h"


@interface DTO : NSObject {
    EntityState entityState;
    NSString * id;
}

@property (nonatomic) EntityState entityState;
@property (nonatomic) NSString *id;

@property(nonatomic) BOOL isNew;

- (id)initWithDictionary:(NSDictionary *)jsonDictionary;
- (NSMutableDictionary *)toDictionary;

@end