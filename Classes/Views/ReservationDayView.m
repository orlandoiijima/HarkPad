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

@synthesize table, dateLabel, countLabels;

- (id)initWithFrame:(CGRect)frame delegate: (id) delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 45)];
        dateLabel.font = [UIFont systemFontOfSize:28];
        dateLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:dateLabel];

        int spacing = 5;
        int width = (frame.size.width - 6 * spacing) / 7;
        int x = 15;
        int y = 40;
        int labelHeight = 20;

        NSArray *labels = [[NSArray alloc] initWithObjects:@"18:00", @"18:30", @"19:00", @"19:30", @"20:00", @"20:30", @"T", nil];
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
    
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, frame.size.width, frame.size.height - 60) style:UITableViewStyleGrouped];
        table.delegate = delegate;
        table.allowsSelectionDuringEditing = YES;
        [self addSubview:table];
    }
    return self;
}

- (Reservation *) selectedReservation
{
    ReservationDataSource *dataSource = table.dataSource;
    NSIndexPath *indexPath = [table indexPathForSelectedRow];	
    return [dataSource getReservation:indexPath];
}

- (ReservationDataSource *) dataSource
{
    return table.dataSource;
}

- (void) setDataSource: (ReservationDataSource *)dataSource
{
    dateLabel.text = [dataSource.date prettyDateString];
    
    [self refreshTotals: dataSource];
    
    table.dataSource = dataSource;
    [table reloadData];
}

- (void) refreshTotals: (ReservationDataSource *)dataSource
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

@end
