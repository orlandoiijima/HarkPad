//
//  OrderLineProperty.h
//  HarkPad
//
//  Created by Willem Bison on 09-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OrderLineProperty : NSObject {
    int id;
    NSString *name;
    NSArray *options;
}

@property int id;
@property (retain) NSString *name;
@property (retain) NSArray *options;

+ (OrderLineProperty *) propertyFromJsonDictionary: (NSDictionary *) dict;

@end