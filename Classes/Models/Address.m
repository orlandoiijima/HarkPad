//
// Created by wbison on 08-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Address.h"


@implementation Address {

}

- (id)  initWithDictionary:(NSMutableDictionary *)dictionary {
    self = [self init];
    if (self == nil) return nil;
    
    self.street = [dictionary objectForKey:@"street"];
    self.zipCode = [dictionary objectForKey:@"zipCode"];
    self.city = [dictionary objectForKey:@"city"];

    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject: self.street forKey:@"street"];
    [dic setObject: self.street forKey:@"zipCode"];
    [dic setObject: self.street forKey:@"city"];
    return dic;
}

@end
