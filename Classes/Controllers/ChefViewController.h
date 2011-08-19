//
//  ChefViewController.h
//  HarkPad
//
//  Created by Willem Bison on 20-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlotDataSource.h"
#import "KitchenStatisticsDataSource.h"

@interface ChefViewController : UIViewController <UIPopoverControllerDelegate>{
    UITableView *table;
    bool isVisible;
}

@property (retain) IBOutlet UITableView *table; 
@property (retain) KitchenStatisticsDataSource *dataSource; 
@property bool isVisible;

- (void) refreshView;
@end
