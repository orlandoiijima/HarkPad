//
//  ReservationDayView.m
//  HarkPad
//
//  Created by Willem Bison on 06-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ReservationDayView.h"
#import "NSDate-Utilities.h"


@implementation ReservationDayView

@synthesize table, dayLabel, dateLabel, countLabels, dataSource, date;

- (id)initWithFrame:(CGRect)frame delegate: (id) delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width/2, 35)];
        dateLabel.font = [UIFont systemFontOfSize:22];
        dateLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:dateLabel];

        dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2 + 5, 0, frame.size.width/2, 35)];
        dayLabel.font = [UIFont systemFontOfSize:22];
        dayLabel.textColor = [UIColor colorWithWhite: 0.5 alpha: 0.5];
        dayLabel.textAlignment = UITextAlignmentLeft;
        [self addSubview:dayLabel];

        int spacing = 5;
        int width = (int) ((frame.size.width - 6 * spacing) / 7);
        int x = 15;
        int y = 40;
        int labelHeight = 20;

        NSArray *labels = [[[NSArray alloc] initWithObjects:@"18:00", @"18:30", @"19:00", @"19:30", @"20:00", @"20:30", @"T", nil] autorelease];
        self.countLabels = [[[NSMutableDictionary alloc] init] autorelease];
        for(NSString *slot in labels)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, labelHeight)];
            label.font = [UIFont systemFontOfSize:10];
            label.textColor = [UIColor grayColor];
            label.text = slot;
            [self addSubview: label];
            
            CGRect bounds = [label textRectForBounds:frame limitedToNumberOfLines:1];
            label = [[UILabel alloc] initWithFrame:CGRectMake(x + bounds.size.width, y, width, labelHeight)];
            label.font = [UIFont systemFontOfSize:10];
            label.text = slot;
            [countLabels setValue:label forKey:slot];
            [self addSubview: label];
            
            x += width + spacing;
        }    
    
        self.dataSource = [[[ReservationDataSource alloc] init] autorelease];

        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, frame.size.width, frame.size.height - 60) style:UITableViewStyleGrouped];
        table.dataSource = self.dataSource;
        table.delegate = delegate;
        table.allowsSelectionDuringEditing = YES;
        [self addSubview:table];
    }
    return self;
}

- (Reservation *) selectedReservation
{
    NSIndexPath *indexPath = [table indexPathForSelectedRow];	
    return [dataSource getReservation:indexPath];
}

- (void) setDataSource: (ReservationDataSource *)aDataSource
{
    NSLog(@"Set datasource");

    self.date = aDataSource.date;
    [dataSource autorelease];
    dataSource = [aDataSource retain];
    table.dataSource = aDataSource;
    [self refreshTotals];

    [table reloadData];
}

- (void) setDate:(NSDate *)aDate
{
    NSLog(@"Set date %@", aDate);
    [date autorelease];
    date = [aDate retain];
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
    [table release];
    [dayLabel release];
    [dateLabel release];
    [countLabels release];
    [date release];
    [dataSource release];
    [super dealloc];
}

@end
