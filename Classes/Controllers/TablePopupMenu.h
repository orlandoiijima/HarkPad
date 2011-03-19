//
//  TablePopupMenu.h
//  HarkPad2
//
//  Created by Willem Bison on 30-11-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Table.h"
#import "Order.h"

typedef enum Command {commandGetOrder, commandStartNextCourse, commandMakeBill, commandGetPayment, commandPlaceReservation} Command ;

@interface TablePopupMenu : UITableViewController {
}

+ (TablePopupMenu *) menuForTable: (Table *) table withOrder: (Order *) order;

@property (retain) Table *table;
@property (retain) Order *order;
@property (retain) UIPopoverController *popoverController;
@property (retain) NSMutableDictionary *commandItems;

@property (retain) NSMutableArray *reservations;
@property (retain) NSMutableDictionary *groupedReservations;

@end
