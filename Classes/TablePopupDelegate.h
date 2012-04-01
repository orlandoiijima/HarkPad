//
//  Created by wbison on 07-02-12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "Order.h"

@class TableWithSeatsView;


@protocol TablePopupDelegate <NSObject>
@optional
- (void) editOrder: (Order *) order;
- (void) makeBillForOrder: (Order *) order;
- (void) getPaymentForOrder: (Order *) order;
- (void) startNextCourseForOrder: (Order *) order;
- (void) didTapSeat: (int)seatOffset;
- (void) didSelectSeat: (int)seatOffset;
- (BOOL) canSelectSeat: (int)seatOffset;
- (void) didTapTableView: (TableWithSeatsView *)tableView;
- (BOOL) canSelectTableView: (TableWithSeatsView *)tableView;
- (void) didSelectTableView: (TableWithSeatsView *)tableView;
- (void) didChangeToPageView: (UIView *)view;
- (void) didTapCloseButton;
@end

