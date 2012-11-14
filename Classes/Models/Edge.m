//
// Created by wbison on 14-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Edge.h"


@implementation Edge {

}

- (Edge *) initWithDictionary:(NSMutableDictionary *)dictionary {
    self = [self init];
    self.left = [[dictionary objectForKey:@"left"] intValue];
    self.top = [[dictionary objectForKey:@"top"] intValue];
    self.right = [[dictionary objectForKey:@"right"] intValue];
    self.bottom = [[dictionary objectForKey:@"bottom"] intValue];
    return self;
    
}
@end