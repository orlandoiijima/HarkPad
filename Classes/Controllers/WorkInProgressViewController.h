//
//  WorkInProgressViewController.h
//  HarkPad
//
//  Created by Willem Bison on 20-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkInProgressDataSource.h"


@interface WorkInProgressViewController : UIViewController <UITableViewDelegate> {
    UITableView *table;
    bool isVisible;
}

@property (retain) IBOutlet UITableView *table;
@property (retain) WorkInProgressDataSource *dataSource; 
@property bool isVisible;

@end
