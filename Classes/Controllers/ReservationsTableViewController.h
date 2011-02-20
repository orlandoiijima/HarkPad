//
//  ReservationsTableViewController.h
//  HarkPad
//
//  Created by Willem Bison on 13-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReservationsTableViewController : UITableViewController {
    NSMutableArray *reservations;
}

@property (retain) NSMutableArray *reservations;
@property (retain) NSMutableDictionary *groupedReservations;
@end
