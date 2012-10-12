//
//  MenuPanelViewController.m
//  HarkPad
//
//  Created by Willem Bison on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuPanelViewController.h"
#import "CategoryPanelView.h"
#import "ProductPanelView.h"
#import "ProductCategory.h"
#import "Menu.h"
#import "Product.h"
#import "Cache.h"
#import "MenuCard.h"
#import "MenuPanelView.h"

@interface MenuPanelViewController ()

@end

@implementation MenuPanelViewController
@synthesize categoryPanelView = _categoryPanelView;
@synthesize productPanelView = _productPanelView;
@synthesize categories = _categories;
@synthesize menuCard = _menuCard;


+ (MenuPanelViewController *) controllerWithMenuCard:(MenuCard *)menuCard {
    MenuPanelViewController *controller = [[MenuPanelViewController alloc] init];

    controller.menuCard = menuCard;
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
    self.view = [MenuPanelView viewWithFrame:CGRectMake(0, 0, 100, 100) menuCard: self.menuCard delegate:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
