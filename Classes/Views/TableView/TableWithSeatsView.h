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
#import "TableViewContainer.h"

@interface TableWithSeatsView : UIView <ItemPropertiesDelegate, UIGestureRecognizerDelegate>

@property (retain) TableViewContainer *tableView;
@property (retain) UIButton *closeButton;
@property (retain) Table *table;
@property (retain) OrderInfo *orderInfo;
@property (retain) id<TablePopupDelegate> delegate;
@property (nonatomic,retain) UIView *contentTableView;
@property (retain) NSMutableArray * selectedGuests;
@property (nonatomic) BOOL isTableSelected;
@property (nonatomic) BOOL isDragging;
@property (nonatomic) BOOL isCloseButtonVisible;
@property (retain) SeatView *spareSeatView;

+ (TableWithSeatsView *) viewWithFrame: (CGRect)frame tableInfo: (TableInfo *)tableInfo showSeatNumbers: (BOOL)showSeatNumbers;
- (void)tapSeat: (id)sender;
- (void) selectSeat: (int) offset;
- (void)didModifyItem:(id)item;
- (SeatView *)seatViewAtOffset: (NSUInteger)offset;
- (SeatView *)seatViewAtPoint: (CGPoint) point exclude:(SeatView *)seatViewToExclude;
- (void) setOverlayText: (NSString *) text forSeat: (int)offset;
- (TableSide) tableSideSeatSectionAtPoint: (CGPoint) point;
- (void) moveSeat: (int) seatToMove toSeat:(int) toSeat atSide:(TableSide)toSide;
- (void) removeSeat:(int) seat;
@end