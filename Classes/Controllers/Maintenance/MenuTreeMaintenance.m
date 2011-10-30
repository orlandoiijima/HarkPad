//
//  MenuTreeMaintenance.m
//  HarkPad
//
//  Created by Willem Bison on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MenuTreeMaintenance.h"
#import "ProductListViewController.h"
#import "GridView.h"
#import "Utils.h"
#import "Cache.h"
#import "GridViewController.h"
#import "MenuTreeView.h"

@implementation MenuTreeMaintenance

@synthesize menuViewController, productViewController;

#define COUNT_PANEL_COLUMNS 3

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
    // Do any additional setup after loading the view from its nib.
    
    MenuTreeView *menuView = [[MenuTreeView alloc] init];
    [self.view addSubview: menuView];
    menuView.frame = CGRectMake(self.view.frame.origin.x, 44, self.view.frame.size.width/2, self.view.frame.size.height);
    menuView.leftHeaderWidth = 0;
    menuView.topHeaderHeight = 0;

    productViewController = [[ProductListViewController alloc] init];
    [self.view addSubview: self.productViewController.view];
    self.productViewController.view.frame = CGRectMake(
            self.view.frame.origin.x + menuView.frame.size.width,
            44,
            self.view.frame.size.width - menuView.frame.size.width,
            self.view.frame.size.height);

    [menuView reloadData];
    [menuView setNeedsDisplay];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


@end
