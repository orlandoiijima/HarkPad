//
//  ChefViewController.m
//  HarkPad
//
//  Created by Willem Bison on 20-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ChefViewController.h"
#import "KitchenStatistics.h"
#import "Service.h"
#import "BacklogViewController.h"
#import "KitchenStatisticsDataSource.h"

@implementation ChefViewController

@synthesize table;
@synthesize isVisible, dataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [NSTimer scheduledTimerWithTimeInterval:10.0f
                                     target:self
                                   selector:@selector(refreshView)
                                   userInfo:nil
                                    repeats:YES];    
    
    [self refreshView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isVisible = true;
    [self refreshView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    isVisible = false;
}


- (void)viewDidUnload
{
    [super viewDidUnload];	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) refreshView
{	    
    if(isVisible == false) return;

    dataSource = [KitchenStatisticsDataSource dataSource];
    table.dataSource = dataSource;
    table.delegate = dataSource;
    
    [table reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
