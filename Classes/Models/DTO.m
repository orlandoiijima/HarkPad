//
//  Created by wbison on 04-03-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DTO.h"


@implementation DTO {

}

@synthesize id, entityState;


- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.entityState = EntityStateNew;
        self.id = -1;
	}
    return(self);
}

- (id)initWithJson:(NSDictionary *)jsonDictionary {
    self = [self init];
    self.id = [[jsonDictionary objectForKey:@"id"] intValue];
    self.entityState = EntityStateNone;
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (entityState != EntityStateNew)
        [dic setObject: [NSNumber numberWithInt:self.id] forKey:@"id"];
    [dic setObject: [NSNumber numberWithInt:entityState] forKey:@"entityState"];
    return dic;
}

- (void) setEntityState:(EntityState)newState
{
    if(entityState == EntityStateNone || newState == EntityStateDeleted || newState == EntityStateNone)
        entityState = newState;
}

- (BOOL) isNew {
    return entityState == EntityStateNew;
}
@end