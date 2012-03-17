//
//  NewOrderViewController.h
//  HarkPad
//
//  Created by Willem Bison on 02/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProductPanelView.h"
#import "TableView.h"
#import "MenuTreeView.h"
#import "OrderDataSource.h"
#import "TableOverlaySimple.h"
#import "TableOverlayHud.h"

@interface NewOrderViewController : UIViewController <MenuTreeViewDelegate, UITableViewDelegate, OrderDelegate, TablePopupDelegate, ProgressDelegate> {
    Course *selectedCourse;
}

@property (retain) MenuTreeView *productPanelView;
@property (retain) TableView *tableView;
@property (retain) TableOverlayHud *tableOverlayHud;
@property (retain) UITableView *orderView;
@property (retain) Order *order;
@property (retain) OrderDataSource *dataSource;
@property (retain) Course *selectedCourse;
@property (retain) Guest *selectedGuest;
@property int selectedCourseOffset;
@property int selectedSeat;

- (void) selectOrderLineForGuest: (Guest *)guest course: (Course *)course;
- (void) selectNextGuest;
- (void) selectNextCourse;
- (CollapseTableViewHeader *) headerViewForSection:(NSInteger)section;
- (int) courseOffsetFromSection: (int) section;

@end
