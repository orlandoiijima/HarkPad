//
//  Invoice.m
//  HarkPad
//
//  Created by Willem Bison on 20-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Invoice.h"
#import "Cache.h"

@implementation Invoice

@synthesize table, createdOn, amount, orderId, paymentType;

+ (Invoice *) invoiceFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Invoice *invoice = [[[Invoice alloc] init] autorelease];
    int tableId = [[jsonDictionary objectForKey:@"tableId"] intValue];
    invoice.table = [[[Cache getInstance] map] getTable:tableId];
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    id createdOn = [jsonDictionary objectForKey:@"createdOn"];
    invoice.createdOn = [df dateFromString: createdOn];
    invoice.amount = [NSDecimalNumber decimalNumberWithDecimal:[[jsonDictionary objectForKey:@"amount"] decimalValue]];
    invoice.orderId = [[jsonDictionary objectForKey:@"orderId"] intValue];
    invoice.paymentType = [[jsonDictionary objectForKey:@"paymentType"] intValue];
    return invoice;
}

@end
