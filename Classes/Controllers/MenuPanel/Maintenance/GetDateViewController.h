//
//  GetDateViewController.h
//  HarkPad
//
//  Created by Willem Bison on 10/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class CKCalendarView;
@class MenuCard;

@interface GetDateViewController : UIViewController

@property(nonatomic, strong) IBOutlet CKCalendarView * calendarView;
@property (retain) IBOutlet UILabel *caption;
@property(nonatomic, strong) MenuCard *menuCard;

- (IBAction) done;

@end

