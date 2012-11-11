//
// Created by wbison on 10-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DTO.h"
#import "Company.h"
#import "NSData+Base64.h"
#import "Address.h"


@implementation Company {

}


- (id)initFromDictionary:(NSMutableDictionary *)dictionary {
    self = [self init];
    if (self == nil) return nil;

//    self.id = [dictionary objectForKey:@"id"];
    self.name = [dictionary objectForKey:@"name"];
    self.address = [[Address alloc] initFromDictionary:[dictionary objectForKey:@"address"]];
    id logo = [dictionary objectForKey:@"logo"];
    if (logo != nil) {
        self.logo = [UIImage imageWithData: [NSData dataFromBase64String: logo]];
    }

    return self;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject: self.name forKey:@"name"];
    if (_address != nil) {
        [dic setObject: [self.address toDictionary] forKey:@"address"];
    }
    if (_logo != nil)
        [dic setObject: [UIImagePNGRepresentation(_logo) base64EncodedString] forKey:@"logo"];
    return dic;
}

@end