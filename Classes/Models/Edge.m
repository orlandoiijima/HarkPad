//
// Created by wbison on 14-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Edge.h"


@implementation Edge {

}

- (Edge *) initWithString:(NSString *)string {
    self = [self init];
    NSArray *parts = [string componentsSeparatedByString:@","];

    self.left = [parts[0] intValue];
    self.top = [parts[1] intValue];
    self.right = [parts[2]intValue];
    self.bottom = [parts[3]intValue];
    return self;
    
}
@end