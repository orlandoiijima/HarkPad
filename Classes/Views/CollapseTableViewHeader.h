//
//  CollapseTableViewHeader.h
//  HarkPad
//
//  Created by Willem Bison on 02/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDelegate.h"

@class SeatGridView;

//@protocol TableViewHeaderDelegate <NSObject>
//@optional
//- (void) tableView: (UITableView *)tableView collapseSection: (NSUInteger) section;
//- (void) tableView: (UITableView *)tableView expandSection: (NSUInteger) section collapseAllOthers: (BOOL)collapseOthers;
//- (void) tableView: (UITableView *)tableView didClickHeaderForSection: (NSUInteger) section;
//@end
//
@interface CollapseTableViewHeader : UIButton {
    UILabel *label;
    BOOL isSelected;
    BOOL isExpanded;
}

@property NSUInteger section;
@property (retain) id<OrderDelegate> delegate;
@property (retain) UITableView *tableView;
@property (retain) SeatGridView *seatGridView;
@property (retain, nonatomic) UIImageView *imageView;
@property (nonatomic) BOOL isExpanded;
@property (nonatomic) BOOL isSelected;
@property (retain) UILabel *label;
@property (retain) UIButton *expandButton;

- (id)initWithFrame:(CGRect)frame section: (NSUInteger) section delegate: (id<OrderDelegate>) delegate tableView: (UITableView *) tableView guests: (NSMutableArray *)guests isExpanded: (BOOL)expanded isSelected: (BOOL)selected  showSeat: (BOOL)showSeat;

@end
