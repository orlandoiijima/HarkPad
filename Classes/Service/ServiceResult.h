//
//  ServiceResult.h
//  HarkPad
//
//  Created by Willem Bison on 24-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"


@interface ServiceResult : NSObject {
    NSMutableDictionary *notification;
    id jsonData;
    id data;
    NSString *error;
    BOOL isSuccess;
    int id;
}

@property (retain) NSMutableDictionary *notification;
@property (retain) id jsonData;
@property (retain) id data;
@property (retain) NSString *error;
@property BOOL isSuccess;
@property int id;

@property(nonatomic) NSInteger httpStatusCode;

+ (ServiceResult *) resultFromData:(NSData*)data error: (NSError *)error;
- (void) displayError;

@end
