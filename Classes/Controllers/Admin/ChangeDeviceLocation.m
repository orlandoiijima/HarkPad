//
//  ChangeDeviceLocation.m
//  HarkPad
//
//  Created by Willem Bison on 10/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChangeDeviceLocation.h"
#import "LocationsViewController.h"

@interface ChangeDeviceLocation ()

@end

@implementation ChangeDeviceLocation

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
    // Do any additional setup after loading the view from its nib.
    LocationsViewController *locationsViewController = [[LocationsViewController alloc] init];
    [self addChildViewController:locationsViewController];
    locationsViewController.view.frame = CGRectMake(10, 10, 400, 400);
    [self.view addSubview: locationsViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
