//
//  CKCalendarViewController.m
//  HarkPad
//
//  Created by Willem Bison on 10/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CKCalendarViewController.h"
#import "CKCalendarView.h"

@interface CKCalendarViewController ()

@end

@implementation CKCalendarViewController
@synthesize delegate = _delegate;


+ (CKCalendarViewController *) controllerWithDate:(NSDate *)date delegate:(id<CKCalendarDelegate>) delegate {
    CKCalendarViewController *controller = [[CKCalendarViewController alloc] init];
    CKCalendarView *calendarView = (CKCalendarView *)controller.view;
    calendarView.selectedDate = date;
    calendarView.delegate = delegate;
    controller.contentSizeForViewInPopover = calendarView.frame.size;
    return controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    self.view = [[CKCalendarView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
