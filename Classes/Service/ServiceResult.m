//
//  ServiceResult.m
//  HarkPad
//
//  Created by Willem Bison on 24-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ServiceResult.h"

@implementation ServiceResult

@synthesize jsonData, data, id, error, notification, isSuccess;

- (id)init {
    if ((self = [super init])) {
        self.id = -1;
        self.error = @"";
        self.isSuccess = false;
        self.jsonData = [[NSMutableDictionary alloc] init];
        self.notification = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (ServiceResult *) resultFromData:(NSData*)data error: (NSError *)error
{
    ServiceResult *serviceResult = [[ServiceResult alloc] init];
    if (error != nil) {
        serviceResult.error = [error localizedDescription];
        return serviceResult;
    }
    if((NSNull *)data == [NSNull null] || [data length] == 0) {
        serviceResult.error = NSLocalizedString(@"Geen data ontvangen van service", nil);
    }
    else {
        NSError *error = nil;
        NSMutableDictionary *dic = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error ];
        if(error == nil) {
            serviceResult.jsonData =  [dic objectForKey:@"result"];
            if(serviceResult.jsonData != nil) {
                if ([serviceResult.jsonData isKindOfClass:[NSMutableDictionary class]]) {
                    id id = [serviceResult.jsonData objectForKey:@"id"];
                    if (id != nil)
                        serviceResult.id = [id intValue];
                }
                serviceResult.isSuccess = true;
            }
            id error =  [dic objectForKey:@"error"];
            if(error != nil) {
                serviceResult.error = [dic objectForKey:@"error"];
            }
        }
    }
    return serviceResult;
    
}

@end
