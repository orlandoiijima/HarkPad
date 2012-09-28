//
// Created by wbison on 28-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Location.h"


@implementation Location {

}
@synthesize name = _name;
@synthesize id = _id;


+ (Location *) locationFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Location *location = [[Location alloc] init];
    location.name = [jsonDictionary objectForKey:@"name"];
    location.id = [[jsonDictionary objectForKey:@"id"] intValue];
    return location;
}

@end