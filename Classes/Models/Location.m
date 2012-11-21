//
// Created by wbison on 28-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DTO.h"
#import "Location.h"
#import "NSData+Base64.h"
#import "Address.h"


@implementation Location {

}
@synthesize name = _name;
@synthesize logo = _logo;

- (Location *)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self == nil) return nil;
    self.name = [dictionary objectForKey:@"name"];
    self.phone = [dictionary objectForKey:@"phone"];
    self.address = [[Address alloc] initWithDictionary: [dictionary objectForKey:@"address"]];
    id logo = [dictionary objectForKey:@"logo"];
    if (logo != nil) {
        self.logo = [UIImage imageWithData: [NSData dataFromBase64String: logo]];
    }
    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject: _name forKey:@"name"];
    if (_address != nil) {
        [dic setObject: [self.address toDictionary] forKey:@"address"];
    }
    if (_phone != nil)
        [dic setObject: self.name forKey:@"phone"];
    if (_logo != nil)
        [dic setObject: [UIImagePNGRepresentation(_logo) base64EncodedString] forKey:@"logo"];
    return dic;
}

- (void)setLogo:(UIImage *)logo {
    _logo = logo;
    entityState = EntityStateModified;
}

- (void)setName:(id)name {
    _name = name;
    entityState = EntityStateModified;
}

@end