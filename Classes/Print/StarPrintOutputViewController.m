//
//  StarPrintOutputViewController.m
//  HarkPad
//
//  Created by Willem Bison on 11/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StarPrintOutputViewController.h"

@interface StarPrintOutputViewController ()

@end

@implementation StarPrintOutputViewController

+(StarPrintOutputViewController *)controllerWithImage:(UIImage *)image {
    StarPrintOutputViewController *controller = [[StarPrintOutputViewController alloc] init];
    ((UIImageView *)controller.view).image = image;
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
    self.view = [[UIImageView alloc] init];
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
