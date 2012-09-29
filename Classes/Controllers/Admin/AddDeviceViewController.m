//
//  AddDeviceViewController.m
//  HarkPad
//
//  Created by Willem Bison on 09/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddDeviceViewController.h"

@interface AddDeviceViewController ()

@end

@implementation AddDeviceViewController

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

/*
        [[Service getInstance]
                registerDeviceWithCredentials: credentials
                success:^(ServiceResult *serviceResult) {
                    [AppVault setDatabase:[serviceResult.jsonData objectForKey:@"database"]];
                    [AppVault setDeviceKey:[serviceResult.jsonData objectForKey:@"deviceKey"]];
                    [AppVault setLocationId:[[serviceResult.jsonData objectForKey:@"locationId"] intValue]];
                    [AppVault setLocation:[serviceResult.jsonData objectForKey:@"location"]];
                }
                error:^(ServiceResult *result) {
                    [result displayError];
                }
        ];
*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
