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
@synthesize id = _id;
@synthesize logo = _logo;

+ (Location *) locationFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Location *location = [[Location alloc] init];
    location.name = [jsonDictionary objectForKey:@"name"];
    location.phone = [jsonDictionary objectForKey:@"phone"];
    location.address = [[Address alloc] initWithDictionary: [jsonDictionary objectForKey:@"address"]];
    id logo = [jsonDictionary objectForKey:@"logo"];
    if (logo != nil) {
        location.logo = [UIImage imageWithData: [NSData dataFromBase64String: logo]];
    }
    return location;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject: self.name forKey:@"name"];
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