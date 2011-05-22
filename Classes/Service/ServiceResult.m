//
//  ServiceResult.m
//  HarkPad
//
//  Created by Willem Bison on 24-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ServiceResult.h"

@implementation ServiceResult

@synthesize data, id, error, isSuccess;

- (id)init {
    if ((self = [super init])) {
        self.id = -1;
        self.error = @"";
        self.isSuccess = false;
        self.data = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (ServiceResult *) resultFromData:(NSData*)data
{
    ServiceResult *serviceResult = [[[ServiceResult alloc] init] autorelease];
    if((NSNull *)data == [NSNull null] || [data length] == 0) {
        serviceResult.error = NSLocalizedString(@"Geen data ontvangen van service", nil);
    }
    else {
        NSError *error = nil;
        serviceResult.data = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error ];
        if(error == nil) {
            id result =  [serviceResult.data objectForKey:@"result"];
            if(result != nil) {
                serviceResult.id = [[result objectForKey:@"id"] intValue];
                serviceResult.isSuccess = true;
            }
            id error =  [serviceResult.data objectForKey:@"error"];
            if(error != nil) {
                serviceResult.error = [serviceResult.data objectForKey:@"error"];
            }
        }
    }
    return serviceResult;
    
}
@end
