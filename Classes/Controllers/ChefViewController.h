//
//  ChefViewController.h
//  HarkPad
//
//  Created by Willem Bison on 20-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlotDataSource.h"

@interface ChefViewController : UIViewController <UITableViewDelegate> {
    UITableView *firstTable;
    UITableView *secondTable;
    SlotDataSource *firstSlotDataSource;
    SlotDataSource *secondSlotDataSource;
    NSMutableArray *slots;
}

@property (retain) IBOutlet UITableView *firstTable; 
@property (retain) IBOutlet UITableView *secondTable; 
@property (retain) IBOutlet UIButton *startNextSlotButton;
@property (retain) SlotDataSource *firstSlotDataSource; 
@property (retain) SlotDataSource *secondSlotDataSource;
@property (retain) NSMutableArray *slots;
@property (retain) IBOutlet UILabel *clockLabel;
- (void) refreshView;
- (void) updateClock;
- (IBAction) startNextSlot;
@end
