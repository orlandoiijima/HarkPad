//
//  DashboardViewController.h
//  HarkPad
//
//  Created by Willem Bison on 04-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"

@interface DashboardViewController : PullToRefreshTableViewController {
    NSMutableDictionary *data;
    NSDate *lastUpdate;
    NSMutableDictionary *sections;
    NSMutableDictionary *labels;
}

@property (retain) NSMutableDictionary *data;
@property (retain) NSDate *lastUpdate;
@property (retain) NSMutableDictionary *sections;
@property (retain) NSMutableDictionary *images;
@property (retain) NSMutableDictionary *labels;

- (void) reloadTableViewDataSource;

@end
