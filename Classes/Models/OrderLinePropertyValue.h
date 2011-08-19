	//
//  OrderLinePropertyValue.h
//  HarkPad
//
//  Created by Willem Bison on 09-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderLineProperty.h"

@interface OrderLinePropertyValue : NSObject {
    int id;
    OrderLineProperty *orderLineProperty;
    NSString *value;
}

@property int id;
@property (retain) OrderLineProperty *orderLineProperty;
@property (retain) NSString *value;

+ (OrderLinePropertyValue *) valueFromJsonDictionary: (NSDictionary *)jsonDictionary;
- (NSString *) displayValue;
- (NSDictionary *)toDictionary;

@end
