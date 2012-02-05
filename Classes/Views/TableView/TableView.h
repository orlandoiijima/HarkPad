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
#import "XTTabBarViewController.h"


@protocol TableViewDelegate <NSObject>
@optional
- (void) didTapSeat: (int)seatOffset;
@end

@interface TableView : UIView <ItemPropertiesDelegate>

@property (retain) UIView *tableView;
@property (retain) Table *table;
@property (retain) Order *order;
@property (retain) XTTabBarViewController *tabBarController;
@property (retain) id<TableViewDelegate> delegate;

+ (TableView *) viewWithFrame: (CGRect)frame order: (Order *)order;
- (void)tapSeat: (id)sender;
- (void) selectSeat: (int) offset;
- (void)didModifyItem:(id)item;
- (SeatView *)seatViewAtOffset: (NSUInteger)offset;
- (CGRect) rectInTableForSeat: (NSUInteger)seat;

@end