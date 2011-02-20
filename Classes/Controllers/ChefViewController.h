//
//  ChefViewController.h
//  HarkPad
//
//  Created by Willem Bison on 20-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Slot.h"

@interface ChefViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *firstTable;
    UITableView *secondTable;
    Slot *firstSlot;
    Slot *secondSlot;
}

@property (retain) IBOutlet UITableView *firstTable; 
@property (retain) IBOutlet UITableView *secondTable; 
@property (retain) Slot *firstSlot; 
@property (retain) Slot *secondSlot; 

@end
