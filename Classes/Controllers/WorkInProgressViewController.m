		//
//  WorkInProgressViewController.m
//  HarkPad
//
//  Created by Willem Bison on 20-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "WorkInProgressViewController.h"
#import "ModalAlert.h"

@implementation WorkInProgressViewController

@synthesize table, isVisible;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {				
    }
    return self;
}

- (void) refreshTimer
{
    [table reloadData];
    
}

- (void) refreshView
{
    if(isVisible == false) return;

    [[Service getInstance] getWorkInProgress: self callback:@selector(refreshViewCallback:)];
}

- (void) refreshViewCallback:(NSMutableArray *)workInProgress
{
    WorkInProgressDataSource *dataSource = [[WorkInProgressDataSource alloc] init];
    dataSource.workInProgress = workInProgress;
    
    table.dataSource = dataSource;
    
    [table reloadData];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WorkInProgressDataSource *dataSource = table.dataSource;
    WorkInProgress *work = [dataSource.workInProgress objectAtIndex:indexPath.row];
    NSString *query = [NSString stringWithFormat:@"Tafel %@ serveren ?", work.table.name];
    if([ModalAlert confirm:query]) {
        [[Service getInstance] serveCourse:work.course.id];	
        [self refreshView];		
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    WorkInProgressDataSource *dataSource = table.dataSource;
    WorkInProgress *work = [dataSource.workInProgress objectAtIndex:indexPath.row];
    int minutes = (int) ((float)[[NSDate date] timeIntervalSinceDate: work.course.requestedOn] / 60);
    if(minutes > 20)
        cell.backgroundColor = [UIColor colorWithRed:0.89 green:0.334 blue:0.0195 alpha:1];
    else if(minutes > 18)
        cell.backgroundColor = [UIColor colorWithRed:0.89 green:0.4531 blue:0.0195 alpha:1];
    else if(minutes > 15)
        cell.backgroundColor = [UIColor colorWithRed:0.89 green:0.676 blue:0.0195 alpha:1];
    else if(minutes > 10)
        cell.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.0195 alpha:1];
    else
        cell.backgroundColor = [UIColor colorWithRed:0.676 green:0.89 blue:0.0195 alpha:1];
	}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [NSTimer scheduledTimerWithTimeInterval:15.0f
                                     target:self
                                   selector:@selector(refreshTimer)
                                   userInfo:nil
                                    repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:60.0f
                                     target:self
                                   selector:@selector(refreshView)
                                   userInfo:nil
                                    repeats:YES];
    table.delegate = self;
    [self refreshView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
