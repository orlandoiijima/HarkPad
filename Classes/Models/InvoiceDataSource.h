//
//  InvoiceDataSource.h
//  HarkPad
//
//  Created by Willem Bison on 05-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@interface InvoiceDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>{
    NSMutableDictionary *lines;
}
@property (retain) NSMutableDictionary *groupedLines;
@property OrderGrouping grouping;
@property (retain) Order *order;

+ (InvoiceDataSource *) dataSourceForOrder: (Order *)order grouping: (OrderGrouping) grouping;

- (NSString *) groupingKeyForLine: (OrderLine *)line;
- (void) addLineToGroup: (OrderLine *)line group: (NSMutableArray *) group;

@end
