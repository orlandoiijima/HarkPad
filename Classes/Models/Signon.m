//
// Created by wbison on 09-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Signon.h"
#import "NSData+Base64.h"


@implementation Signon {

}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:self.name forKey:@"name"];
    [dic setObject: self.password forKey:@"password"];
    [dic setObject: self.email forKey:@"email"];
    [dic setObject: self.firstName forKey:@"firstName"];
    [dic setObject: self.surName forKey:@"surName"];
    [dic setObject: self.pinCode forKey:@"pinCode"];
    if (_logo != nil)
        [dic setObject: [UIImagePNGRepresentation(_logo) base64EncodedString] forKey:@"logo"];

    return dic;
}

@end