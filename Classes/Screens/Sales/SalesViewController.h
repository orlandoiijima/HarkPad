//
//  SalesViewController.h
//  HarkPad
//
//  Created by Willem Bison on 09-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SalesViewController : UIViewController {
    NSMutableDictionary *groupedTotals;
    NSDate *dateToShow;
}

@property (retain) NSMutableDictionary *groupedTotals;
@property (retain) NSDate *dateToShow;
@property (retain) IBOutlet UILabel *dateLabel;
@property (retain) IBOutlet UITableView *tableAmounts;

- (NSString *) keyForSection: (int) section;
- (void) refreshView;
- (IBAction)handleSwipeGesture:(UISwipeGestureRecognizer *)sender;
- (IBAction)handleDoubleTapGesture:(UITapGestureRecognizer *)sender;
- (UILabel *) addAmountLabelWithFrame: (CGRect) frame cell: (UITableViewCell *)cell;
- (IBAction) printDayReport;
@end
