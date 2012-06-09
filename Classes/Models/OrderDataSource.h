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
#import "OrderDelegate.h"
#import "OrderDataSourceSection.h"
#import "CollapseTableViewHeader.h"
#import "OrderLineCell.h"

typedef enum OrderLineSortOrder {sortByOrder, sortByCreatedOn, sortByCategory} OrderLineSortOrder;

@interface OrderDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>{
    NSMutableDictionary *groupedLines;
    OrderGrouping grouping;
    bool totalizeProducts;
    bool showFreeProducts;
    bool showProductProperties;
    bool showPrice;
    bool showSeat;
    bool collapsableHeaders;
    bool showEmptySections;
    bool showStepper;
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
@property bool showSeat;
@property bool showStepper;
@property bool showEmptySections;
@property bool isEditable;
@property bool collapsableHeaders;
@property (retain, nonatomic) id<OrderDelegate> delegate;
@property (retain) Order *order;
@property float rowHeight;
@property float fontSize;
@property OrderLineSortOrder sortOrder;

+ (OrderDataSource *) dataSourceForOrder: (Order *)order grouping: (OrderGrouping) grouping totalizeProducts: (bool) totalize showFreeProducts: (bool)showFree showProductProperties: (bool)showProps isEditable: (bool)isEditable showPrice: (bool)showPrice showEmptySections: (BOOL) showEmptySections fontSize: (float)fontSize;

- (NSNumber *) keyForCourse: (Course *)course;
- (NSNumber *) keyForGuest: (Guest *)guest;
- (NSNumber *) keyForOrderLine: (OrderLine *)line;
- (NSNumber *) keyForSection:(int)section;
- (int) sectionForKey:(NSNumber *) key;
- (OrderDataSourceSection *) groupForSection:(int) section;
- (OrderLine *) orderLineAtIndexPath: (NSIndexPath *)indexPath;
- (void) tableView:(UITableView *)tableView addLine: (OrderLine *)line;
- (int) insertionPointForLine: (OrderLine *)lineToInsert inGroup: (OrderDataSourceSection *)group;
- (NSIndexPath *)indexPathForLine: (OrderLine *)line;
- (void) tableView:(UITableView *)tableView removeOrderLine:(OrderLine *)line;
- (NSMutableArray *)getGuestsForProduct: (Product *)product andKey: (NSNumber *)aKey;
- (void) tableView:(UITableView *)tableView collapseSection: (NSUInteger)section;
- (void) tableView:(UITableView *)tableView expandSection: (NSUInteger)sectionToExpand collapseAllOthers:(BOOL)collapseOthers;
- (void) tableView:(UITableView *)tableView addSection: (int) section;
- (void)tableView:(UITableView *)tableView totalizeProducts: (BOOL)totalize;
-(void) logDataSource;
- (void) highlightRowsInTableView:(UITableView *)tableView forSeat:(int)seat;

@end
