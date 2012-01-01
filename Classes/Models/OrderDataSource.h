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
#import "TableCellUpdated.h"

typedef enum OrderLineSortOrder {sortByOrder, sortByCreatedOn, sortByCategory} OrderLineSortOrder;

@interface OrderDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>{
    NSMutableDictionary *groupedLines;
    OrderGrouping grouping;
    bool totalizeProducts;
    bool showFreeProducts;
    bool showProductProperties;
    bool showPrice;
    float fontSize;
    Order *order;
    OrderLineSortOrder sortOrder;
}

@property (retain) NSMutableDictionary *groupedLines;
@property (nonatomic) OrderGrouping grouping;
@property bool totalizeProducts;
@property bool showFreeProducts;
@property bool showProductProperties;
@property bool showPrice;
@property bool isEditable;
@property (retain, nonatomic) id<TableCellUpdated> delegate;
@property (retain) Order *order;
@property (retain) InvoicesViewController *invoicesViewController;
@property float rowHeight;
@property float fontSize;
@property OrderLineSortOrder sortOrder;

+ (OrderDataSource *) dataSourceForOrder: (Order *)order grouping: (OrderGrouping) grouping totalizeProducts: (bool) totalize showFreeProducts: (bool)showFree showProductProperties: (bool)showProps isEditable: (bool)isEditable showPrice: (bool)showPrice fontSize: (float)fontSize;

- (NSString *) groupingKeyForLine: (OrderLine *)line;
- (NSString *) keyForSection:(int)section;
- (int) sectionForKey:(NSString *) key;
- (NSMutableArray *) groupForSection:(int) section;
- (OrderLine *) orderLineAtIndexPath: (NSIndexPath *)indexPath;
- (void) tableView:(UITableView *)tableView addLine: (OrderLine *)line;
- (int) insertionPointForLine: (OrderLine *)lineToInsert inGroup: (NSMutableArray *)group;
- (NSIndexPath *)indexPathForLine: (OrderLine *)line;
- (void) tableView:(UITableView *)tableView removeOrderLine:(OrderLine *)line;
@end