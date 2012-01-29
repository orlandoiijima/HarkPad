//
//  Created by wbison on 27-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SimpleTableView.h"
#import "SeatView.h"
#import "Table.h"
#import "ItemPropertiesDelegate.h"


@protocol TableViewDelegate <NSObject>
@optional
- (void) didTapSeat: (int)seatOffset;
@end

@interface TableView : UIView <ItemPropertiesDelegate>

//@property (retain) NSMutableArray *seatViews;
@property (retain) SimpleTableView *tableView;
@property (retain) Table *table;

@property (retain) id<TableViewDelegate> delegate;
@property (assign) UIView *tableContentView;

+ (TableView *) viewWithFrame: (CGRect)frame table: (Table *)table;
- (void)tapSeat: (id)sender;
- (void) selectSeat: (int) offset;
- (void)didModifyItem:(id)item;

@end