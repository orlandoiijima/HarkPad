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

@class SeatSlider;

typedef enum SeatViewMode {SeatViewModeShowSeats, SeatViewModeSlider} SeatViewMode;

@interface TableWithSeatsView : UIView <ItemPropertiesDelegate, UIGestureRecognizerDelegate>

@property (retain) TableViewContainer *tableView;
@property (retain) UIButton *closeButton;
@property (retain) Table *table;
@property (retain) id<OrderProxyDelegate> orderInfo;
@property (retain) id<TablePopupDelegate> delegate;
@property (nonatomic,retain) UIView *contentTableView;
@property (retain) NSMutableArray * selectedGuests;
@property (nonatomic) BOOL isTableSelected;
@property (nonatomic) BOOL isDragging;
@property (nonatomic) BOOL isCloseButtonVisible;
@property (nonatomic) BOOL isSpareSeatViewVisible;
@property (retain) SeatView *spareSeatView;
@property (nonatomic) CGSize seatViewSize;
@property (nonatomic) SeatViewMode seatViewMode;

@property(nonatomic, strong) SeatSlider *seatSlider;

+ (TableWithSeatsView *) viewWithFrame: (CGRect)frame tableInfo: (TableInfo *)tableInfo mode:(SeatViewMode)mode;
- (void)tapSeat: (id)sender;
- (void) selectSeat: (int) offset;
- (void)didModifyItem:(id)item;
- (SeatView *)seatViewAtOffset: (NSUInteger)offset;
- (void) setOverlayText: (NSString *) text forSeat: (int)offset;
- (TableSide) tableSideSeatSectionAtPoint: (CGPoint) point;
- (void) moveSeat: (int) seatToMove toSeat:(int) toSeat atSide:(TableSide)toSide;
- (void) removeSeat:(int) seat;
- (void) insertSeatBeforeSeat: (int) toSeat atSide:(TableSide)toSide;
-(int) seatAtPoint:(CGPoint) point;
-(CGRect) frameForSeat:(int) seatToFind;
- (SeatView *) addNewSeatViewAtOffset:(int) seat atSide:(TableSide)side withGuest:(Guest *)guest;
- (void)didSelectSeat: (int)seatOffset;

@end