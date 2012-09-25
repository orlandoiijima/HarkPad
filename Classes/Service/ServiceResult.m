//
//  ServiceResult.m
//  HarkPad
//
//  Created by Willem Bison on 24-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ServiceResult.h"
#import "ModalAlert.h"
#import "Logger.h"

@implementation ServiceResult

@synthesize jsonData, data, id, error, notification, isSuccess;
@synthesize httpStatusCode = _httpStatusCode;


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

+ (ServiceResult *) resultFromData:(NSData*)data error: (NSError *)connectionError
{
    ServiceResult *serviceResult = [[ServiceResult alloc] init];
    serviceResult.httpStatusCode = connectionError.code;
    if((NSNull *)data == [NSNull null] || [data length] == 0) {
        serviceResult.error = NSLocalizedString(@"No data received from server", nil);
    }
    else {
        NSError *error = nil;
//        NSLog([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSMutableDictionary *dic = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error ];
        if(error == nil) {
            switch (serviceResult.httpStatusCode) {
                case 200:
                case 201:
                case 400:
                case 0:
                {
                    serviceResult.jsonData =  [dic objectForKey:@"result"];
                    if(serviceResult.jsonData != nil) {
                        if ([serviceResult.jsonData isKindOfClass:[NSDictionary class]]) {
                            id id = [serviceResult.jsonData objectForKey:@"id"];
                            if (id != nil)
                                serviceResult.id = [id intValue];
                        }
                        serviceResult.isSuccess = true;
                        [Logger Info:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                    }
                    id error =  [dic objectForKey:@"error"];
                    if(error != nil) {
                        serviceResult.error = [dic objectForKey:@"error"];
                    }
                    break;
                }
                case 404:
                case 401:
                case 500:
                default:
                    serviceResult.error = [dic description];
                    break;
            }
        }
        else {
            if ([data length] > 0)
                serviceResult.error = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            else
                serviceResult.error = [error localizedDescription];
        }
    }
    if (serviceResult.isSuccess == false && [serviceResult.error length] > 0)
        [Logger Info:serviceResult.error];

    return serviceResult;
}

- (void) displayError {
    if (isSuccess)
        return;
    NSString *message;
    switch(_httpStatusCode) {
        case 401:
            message = NSLocalizedString(@"Unauthorized access", nil);
            break;
        default:
            message = error;
            break;
    }
    [ModalAlert error: message];
}

@end
