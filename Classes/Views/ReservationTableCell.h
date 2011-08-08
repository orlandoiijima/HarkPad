//
//  ReservationTableCell.h
//  HarkPad
//
//  Created by Willem Bison on 14-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reservation.h"

@interface ReservationTableCell : UITableViewCell {
    UILabel *notes;
    UILabel *name;
    UILabel *count;
    UILabel *email;
    UILabel *phone;
    UIImageView *flag;
    UIButton *status;
}

@property (retain) IBOutlet UILabel *name;
@property (retain) IBOutlet UILabel *count;
@property (retain) IBOutlet UIButton *status;
@property (retain) IBOutlet UILabel *email;
@property (retain) IBOutlet UILabel *phone;
@property (retain) IBOutlet UILabel *notes;
@property (retain) IBOutlet UIImageView *flag;

- (void) setReservation: (Reservation*)reservation;

@end
