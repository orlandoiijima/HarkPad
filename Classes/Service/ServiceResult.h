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
    NSMutableDictionary *data;
    NSString *error;
    int id;    
}

@property (retain) NSMutableDictionary *data;
@property (retain) NSString *error;
@property int id;

+ (ServiceResult *) resultFromData:(NSData*)data;

@end
