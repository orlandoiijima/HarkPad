//
//  OrderLineProperty.m
//  HarkPad
//
//  Created by Willem Bison on 09-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "OrderLineProperty.h"


@implementation OrderLineProperty

@synthesize name, id, options;

+ (OrderLineProperty *) propertyFromJsonDictionary: (NSDictionary *) jsonDictionary
{
    OrderLineProperty *property = [[OrderLineProperty alloc] init];
    property.id = [[jsonDictionary objectForKey:@"id"] intValue];
    property.name = [jsonDictionary objectForKey:@"name"];
    NSString *options = [jsonDictionary objectForKey:@"options"];
    if((NSNull *)options != [NSNull null] && [options length] > 0)
        property.options = [options componentsSeparatedByString:@"|"];
    else
        property.options = [[NSArray alloc] init];
    return property;
}
@end
