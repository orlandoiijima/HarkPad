//
//  GetDateViewController.m
//  HarkPad
//
//  Created by Willem Bison on 10/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GetDateViewController.h"
#import "CKCalendarView.h"
#import "MenuCardViewController.h"
#import "MenuCard.h"

@interface GetDateViewController ()

@end

@implementation GetDateViewController
@synthesize calendarView = _calendarView;
@synthesize menuCard = _menuCard;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Menu", nil);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];

    self.calendarView.frame = CGRectMake((self.view.frame.size.width - self.calendarView.frame.size.width)/2, CGRectGetMaxY(self.caption.frame)+20, self.calendarView.frame.size.width, self.calendarView.frame.size.height);

    self.calendarView.selectedDate = _menuCard.validFrom;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    MenuCardViewController *controller = [MenuCardViewController controllerWithMenuCard: _menuCard];
    _menuCard.validFrom = self.calendarView.selectedDate;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
