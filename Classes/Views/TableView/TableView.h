//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SeatView.h"
#import "Table.h"
#import "ItemPropertiesDelegate.h"
#import "Order.h"
#import "TablePopupDelegate.h"
#import "OrderInfo.h"
#import "TableInfo.h"

@interface TableView : UIView <ItemPropertiesDelegate, UIGestureRecognizerDelegate>

@property (retain) UIView *tableView;
@property (retain) Table *table;
@property (retain) OrderInfo *orderInfo;
@property (retain) id<TablePopupDelegate> delegate;
@property (retain) UIView *contentTableView;
@property CGRect tableInnerRect;
@property (retain) NSMutableArray * selectedGuests;
@property BOOL isTableSelected;
@property BOOL isDragging;

+ (TableView *) viewWithFrame: (CGRect)frame tableInfo: (TableInfo *)tableInfo showSeatNumbers: (BOOL)showSeatNumbers;
- (void)tapSeat: (id)sender;
- (void) selectSeat: (int) offset;
- (void)didModifyItem:(id)item;
- (SeatView *)seatViewAtOffset: (NSUInteger)offset;
- (CGRect) rectInTableForSeat: (NSUInteger)seat;

@end