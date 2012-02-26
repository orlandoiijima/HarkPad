//
//  ReservationDayView.m
//  HarkPad
//
//  Created by Willem Bison on 06-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "ReservationDayView.h"
#import "NSDate-Utilities.h"


@implementation ReservationDayView

@synthesize table, dayLabel, dateLabel, countLabels, dataSource, date, selectedReservation, infoLabel;

- (id)initWithFrame:(CGRect)frame delegate: (id) delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/2, 35)];
        dateLabel.font = [UIFont systemFontOfSize:22];
        dateLabel.textAlignment = UITextAlignmentRight;
        dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:dateLabel];

        dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2 + 5, 0, frame.size.width/2, 35)];
        dayLabel.font = [UIFont systemFontOfSize:22];
        dayLabel.textColor = [UIColor colorWithWhite: 0.5 alpha: 0.5];
        dayLabel.textAlignment = UITextAlignmentLeft;
        dayLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:dayLabel];

        int spacing = 5;
        int width = (int) ((frame.size.width) / 7);
        int x = 0;
        int y = 40;
        int labelHeight = 20;

        NSArray *labels = [[NSArray alloc] initWithObjects:@"18:00", @"18:30", @"19:00", @"19:30", @"20:00", @"20:30", @"T", nil];
        self.countLabels = [[NSMutableDictionary alloc] init];
        for(NSString *slot in labels)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, labelHeight)];
            label.textAlignment = UITextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = [UIColor grayColor];
            label.text = slot;
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [self addSubview: label];
            
            CGRect bounds = [label textRectForBounds:frame limitedToNumberOfLines:1];
            label = [[UILabel alloc] initWithFrame:CGRectMake(x, y + label.bounds.size.height, width, labelHeight)];
            label.textAlignment = UITextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:16];
            label.text = slot;
            [countLabels setValue:label forKey:slot];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [self addSubview: label];
            
            x += width;
        }    
    
        self.dataSource = [[ReservationDataSource alloc] init];

        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, frame.size.width, frame.size.height - 90) style:UITableViewStyleGrouped];
        table.dataSource = self.dataSource;
        table.delegate = delegate;
        table.allowsSelectionDuringEditing = YES;
        table.backgroundView = nil;
        table.backgroundColor = [UIColor clearColor];
        table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:table];

        infoLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 2*(frame.size.height/5), frame.size.width, 40)];
        [self addSubview:infoLabel];
        infoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        infoLabel.textAlignment = UITextAlignmentCenter;
        infoLabel.textColor = [UIColor lightGrayColor];
        infoLabel.hidden = YES;
    }
    return self;
}

- (void) hideHeader
{
    table.frame = CGRectMake(0, 0, table.frame.size.width, self.frame.size.height);
}

- (void) showHeader
{
    table.frame = CGRectMake(0, 60, table.frame.size.width, self.frame.size.height - 60);
}

- (Reservation *) selectedReservation
{
    NSIndexPath *indexPath = [table indexPathForSelectedRow];
    if(indexPath == nil)
        return nil;
    return [dataSource getReservation:indexPath];
}

- (void) setSelectedReservation: (Reservation*) newReservation
{
    NSIndexPath *indexPath = [dataSource getIndexPath:newReservation inTable:table];
    if(indexPath != nil)
        [table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void) setDataSource: (ReservationDataSource *)aDataSource
{
    NSLog(@"Set datasource");

    self.date = aDataSource.date;
    dataSource = aDataSource;
    table.dataSource = aDataSource;
    [self refreshTotals];

    if ([aDataSource.reservations count] == 0)
    {
        [self showInfo:NSLocalizedString(@"No reservations", nil)];
    }
    else
    {
        [self hideInfo];
        [table reloadData];
    }
}

- (void)showInfo: (NSString *)text
{
    infoLabel.text = text;
    infoLabel.hidden = NO;
    table.hidden = YES;
}

- (void)hideInfo
{
    infoLabel.hidden = YES;
    table.hidden = NO;
}

- (void) setDate:(NSDate *)aDate
{
    NSLog(@"Set date %@", aDate);
    date = aDate;
    dateLabel.text = [aDate prettyDateString];
    dayLabel.text = [aDate weekdayString];    
}

- (void) refreshTotals
{
    for(NSString *slot in [countLabels allKeys])
    {
        if([slot isEqualToString:@"T"] == false) {
            int count = [dataSource countGuestsForKey: slot];
            UILabel *label = [countLabels objectForKey:slot];
            label.text = count == 0 ? @" -" : [NSString stringWithFormat:@" %d", count];
        }
    }
    
    int total = [dataSource countGuests];
    UILabel *label = [countLabels objectForKey:@"T"];
    label.text = total == 0 ? @" -" : [NSString stringWithFormat:@" %d", total];
}

- (void)dealloc
{
    NSLog(@"Dealloc ResDayView %@", date);
}

@end
