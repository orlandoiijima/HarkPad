//
//  Invoice.m
//  HarkPad
//
//  Created by Willem Bison on 20-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Invoice.h"
#import "Cache.h"
#import "NSDate-Utilities.h"

@implementation Invoice

@synthesize tableId, createdOn, amount, orderId, paymentType;

+ (Invoice *) invoiceFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Invoice *invoice = [[Invoice alloc] init];
    invoice.tableId = [jsonDictionary objectForKey:@"tableId"];
    NSString *createdOn = [jsonDictionary objectForKey:@"createdOn"];
    invoice.createdOn = [NSDate dateFromISO8601:createdOn];
    invoice.amount = [NSDecimalNumber decimalNumberWithDecimal:[[jsonDictionary objectForKey:@"amount"] decimalValue]];
    invoice.orderId = [[jsonDictionary objectForKey:@"orderId"] intValue];
    invoice.paymentType = [[jsonDictionary objectForKey:@"paymentType"] intValue];
    return invoice;
}

@end
