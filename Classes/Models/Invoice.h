//
//  Invoice.h
//  HarkPad
//
//  Created by Willem Bison on 20-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Table.h"

@interface Invoice : NSObject {
    NSDate *createdOn;
    NSDecimalNumber *amount;
    Table *table;
    int orderId;
    int paymentType;
}

@property (retain) NSDate *createdOn;
@property (retain) NSDecimalNumber *amount;
@property int orderId;
@property int paymentType;
@property (retain) Table *table;

+ (Invoice *) invoiceFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end
