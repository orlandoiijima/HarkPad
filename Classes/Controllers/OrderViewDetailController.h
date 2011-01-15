//
//  OrderViewDetailController.h
//  HarkPad
//
//  Created by Willem Bison on 10-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderLineCell.h"
#import "Order.h"

@interface OrderDetailViewController : UITableViewController <UIPopoverControllerDelegate> {
}

- (id)initWithOrder:(Order *)order;
- (void) setOrderGrouping: (OrderGrouping) group includeExisting: (BOOL)existing;
- (void) refreshSelectedCell;

@property (retain) Order *order;
//@property OrderGrouping orderGrouping; 
@property (retain) NSMutableDictionary *groupedOrderLines;
@property (nonatomic, assign) IBOutlet OrderLineCell *tmpCell;

@end