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

    table.backgroundView = nil;
    
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

    [[Service getInstance]
            getBacklogStatistics:^(ServiceResult *serviceResult){
                            NSMutableArray *stats = [[NSMutableArray alloc] init];
                            for (NSDictionary *statDic in serviceResult.jsonData) {
                                Backlog *backlog = [Backlog backlogFromJsonDictionary:statDic];
                                [stats addObject:backlog];
                            }
                            dataSource = [KitchenStatisticsDataSource dataSourceWithData: stats];
                            table.dataSource = dataSource;
                            table.delegate = dataSource;
                            [table reloadData];
                        }
                           error:^(ServiceResult *serviceResult){
                               [serviceResult displayError];
                           }];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
