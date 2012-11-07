//
//  NewOrderViewController.h
//  HarkPad
//
//  Created by Willem Bison on 02/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TableWithSeatsView.h"
#import "OrderDataSource.h"
#import "TableOverlaySimple.h"
#import "TableOverlayHud.h"
#import "ProductPanelView.h"

@class MenuPanelView;

@interface NewOrderViewController : UIViewController <UITableViewDelegate, OrderDelegate, ProgressDelegate, TablePopupDelegate, ProductPanelDelegate> {
    Course *selectedCourse;
}

@property (retain) MenuPanelView *productPanelView;
@property (retain) TableWithSeatsView *tableView;
@property (retain) TableOverlayHud *tableOverlayHud;
@property (retain) UITableView *orderView;
@property (retain) Order *order;
@property (retain) OrderDataSource *dataSource;
@property (retain) Course *selectedCourse;
@property (retain) Guest *selectedGuest;
@property int selectedCourseOffset;
@property int selectedSeat;

@property(nonatomic, assign) BOOL autoAdvance;

- (void) selectOrderLineForGuest: (Guest *)guest course: (Course *)course;
- (bool) selectNextGuest;
- (void) selectNextCourse;
- (CollapseTableViewHeader *) headerViewForSection:(NSInteger)section;
- (int) courseOffsetFromSection: (int) section;
- (void)updateSeatOverlay;
- (void) addPanelWithView:(UIView *)view frame:(CGRect) frame margin:(int) margin padding:(int) padding backgroundColor: (UIColor *)color;
@end
