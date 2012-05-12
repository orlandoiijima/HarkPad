//
//  Created by wbison on 07-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "Order.h"

@class TableWithSeatsView;

@protocol TablePopupDelegate <NSObject>
@required
//- (void) didSelectReservationForOrder: (Order *) order;
//- (void) didTapSeat: (int)seatOffset;
//- (void) didChangeToPageView: (UIView *)view;
@optional
- (void) didSelectSeat: (int)seatOffset;
- (BOOL) canSelectSeat: (int)seatOffset;
- (BOOL) canSelectTableView: (TableWithSeatsView *)tableView;
- (void) didSelectTableView: (TableWithSeatsView *)tableView;
- (void) didTapTableView: (TableWithSeatsView *)tableView;
- (void) didTapCloseButton;
@end


@protocol TableCommandsDelegate <NSObject>
@required
- (void) makeBillForOrder: (Order *) order;
- (void) getPaymentForOrder: (Order *) order;
- (void) startNextCourseForOrder: (Order *) order;
//- (void) didSelectReservationForOrder: (Order *) order;
- (void) editOrder:(Order *)order;
- (void) updateOrder:(Order *)order;
- (void) closePopup;
@end

