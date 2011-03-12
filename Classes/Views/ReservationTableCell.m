//
//  ReservationTableCell.m
//  HarkPad
//
//  Created by Willem Bison on 14-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ReservationTableCell.h"

@implementation ReservationTableCell

@synthesize reservation, name, count, notes, email, phone, flag;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setReservation: (Reservation*)newReservation
{
    reservation = newReservation;
    self.name.text = reservation.name;
    self.phone.text = reservation.phone;
    self.email.text = reservation.email;
    self.count.text = [NSString stringWithFormat:@"%d", reservation.countGuests];
    self.notes.text = reservation.notes;
    NSString *imageName = [NSString stringWithFormat:@"%@.png", [reservation.language lowercaseString]	];
    self.flag.image = [UIImage imageNamed: imageName];
    if(self.flag.image == nil) 
        self.flag.image = [UIImage imageNamed:@"nl.png"];
}

- (void)dealloc
{
    [super dealloc];
}

@end