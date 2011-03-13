//
//  ReservationsTableViewController.h
//  HarkPad
//
//  Created by Willem Bison on 13-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReservationsTableViewController : UIViewController <UITableViewDelegate>{
    NSMutableArray *reservations;
    NSMutableDictionary *groupedReservations;
    NSDate *dateToShow;
}

@property (retain) IBOutlet UITableView *table; 
@property (retain) IBOutlet UILabel *dateLabel;
@property (retain) NSDate *dateToShow;
@property (retain) NSMutableArray *reservations;
@property (retain) NSMutableDictionary *groupedReservations;

- (void) refreshTable;

@end
