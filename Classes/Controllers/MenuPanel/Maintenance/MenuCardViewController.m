//
//  xMenuCardViewController.m
//  HarkPad
//
//  Created by Willem Bison on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuCardViewController.h"
#import "ProductPropertiesView.h"
#import "MenuPanelView.h"
#import "MenuCard.h"

@interface MenuCardViewController ()

@end

@implementation MenuCardViewController
@synthesize menuPanel = _menuPanel;
@synthesize productProperties = _productProperties;
@synthesize menuCard = _menuCard;


+ (MenuCardViewController *)controllerWithMenuCard:(MenuCard *)card {
    MenuCardViewController *controller = [[MenuCardViewController alloc] init];
    controller.menuCard = card;
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _menuPanel = [MenuPanelView viewWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height) menuCard:_menuCard delegate:self];
    [self.view addSubview:_menuPanel];

    _productProperties = [ProductPropertiesView viewWithFrame: CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, self.view.frame.size.height)];
    [self.view addSubview:_productProperties];

    [_menuPanel setMenuCard: _menuCard];
}

- (void)didTapProduct:(Product *)product {
    _productProperties.product = product;
}

- (void)didTapCategory:(ProductCategory *)category {

    _menuPanel.selectedProduct = [category.products objectAtIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
