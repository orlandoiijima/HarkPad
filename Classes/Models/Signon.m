//
// Created by wbison on 09-08-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Signon.h"


@implementation Signon {

}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: self.tenant forKey:@"name"];
    [dic setObject: self.password forKey:@"password"];
    [dic setObject: self.email forKey:@"email"];
    [dic setObject: self.location forKey:@"location"];
//    [dic setObject: self.ip forKey:@"ip"];
    [dic setObject: self.firstName forKey:@"firstName"];
    [dic setObject:self.surName forKey:@"surName"];

    return dic;
}

@end