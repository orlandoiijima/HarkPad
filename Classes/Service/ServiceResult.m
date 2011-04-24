//
//  ServiceResult.m
//  HarkPad
//
//  Created by Willem Bison on 24-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ServiceResult.h"

@implementation ServiceResult

@synthesize data, id, error;

- (id)init {
    if ((self = [super init])) {
        self.id = -1;
        self.error = @"";
        self.data = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (ServiceResult *) resultFromData:(NSData*)data
{
    ServiceResult *serviceResult = [[[ServiceResult alloc] init] autorelease];
    if((NSNull *)data == [NSNull null] || [data length] == 0) {
        serviceResult.error = @"Geen data ontvangen van service" ;
    }
    else {
        NSError *error = nil;
        NSDictionary *jsonDictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error ];
        if(error == nil) {
            id result =  [jsonDictionary objectForKey:@"result"];
            if((NSNull *)result != [NSNull null]) {
                serviceResult.id = [[result objectForKey:@"id"] intValue];
            
            }
        }
    }
    return serviceResult;
    
}
@end
