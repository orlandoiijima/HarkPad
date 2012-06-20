//
// Created by wbison on 20-06-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


@protocol SelectSeatDelegate <NSObject>
- (void) didSelectSeat: (int) seatOffset;
@end