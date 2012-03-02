			//
//  ReservationTableCell.m
//  HarkPad
//
//  Created by Willem Bison on 14-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ReservationTableCell.h"

@implementation ReservationTableCell

@synthesize name, count, notes, email, phone, flag, status;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    if([self.notes.text length] == 0)
        self.name.frame = CGRectMake(self.name.frame.origin.x, self.name.frame.origin.y, self.contentView.frame.size.width, self.name.frame.size.height);
    self.notes.frame = CGRectMake(self.notes.frame.origin.x,
                                  self.notes.frame.origin.y,
                                  self.contentView.frame.size.width - self.notes.frame.origin.x,
                                  self.notes.frame.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setReservation: (Reservation*)reservation
{
    if(reservation.type == ReservationTypeWalkin) {
        self.name.text = NSLocalizedString(@"walk-in", nil);
        self.name.font = [UIFont italicSystemFontOfSize: self.name.font.pointSize];
        self.name.textColor = [UIColor blueColor];		
    }
    else {
        self.name.text = [reservation.name capitalizedString];
    }
    self.email.text = reservation.email;
    self.count.text = [NSString stringWithFormat:@"%d", reservation.countGuests];
    if(reservation.table != nil)
    {
        self.count.textColor = [UIColor lightGrayColor];
        self.phone.text = [NSString stringWithFormat:@"Tafel %@", reservation.table.name];
        self.phone.textColor = [UIColor blueColor];
    }
    else
    {
        self.phone.text = reservation.phone;
    }
    self.notes.text = reservation.notes;
    NSString *imageName = [NSString stringWithFormat:@"%@.png", [reservation.language lowercaseString]	];
    self.flag.image = [UIImage imageNamed: imageName];
    if(self.flag.image == nil) 
        self.flag.image = [UIImage imageNamed:@"nl.png"];
}


@end		
