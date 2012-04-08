//
//  Created by wbison on 08-04-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSString+Utilities.h"


@implementation NSString (Utilities)

- (NSString *)capitalizeFirstLetter {
    NSString *firstCapChar = [[self substringToIndex:1] capitalizedString];
    return [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
}

@end