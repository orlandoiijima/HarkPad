//
//  InvoiceDataSource.h
//  HarkPad
//
//  Created by Willem Bison on 05-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"
#import "ServiceResult.h"
#import "InvoicesViewController.h"

@interface InvoiceDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>{
    NSMutableDictionary *lines;
    NSMutableDictionary *groupedLines;
    OrderGrouping grouping;
    bool totalizeProducts;
    bool showFreeProducts;
    Order *order;
}

@property (retain) NSMutableDictionary *groupedLines;
@property (nonatomic) OrderGrouping grouping;
@property bool totalizeProducts;
@property bool showFreeProducts;
@property (retain) Order *order;
@property (retain) InvoicesViewController *invoicesViewController;

+ (InvoiceDataSource *) dataSourceForOrder: (Order *)order grouping: (OrderGrouping) grouping totalizeProducts: (bool) totalize showFreeProducts: (bool)showFree;

- (NSString *) groupingKeyForLine: (OrderLine *)line;
- (void) addLineToGroup: (OrderLine *)line group: (NSMutableArray *) group;
- (NSString *) keyForSection:(int)section;
- (NSMutableArray *) groupForSection:(int) section;

@end
