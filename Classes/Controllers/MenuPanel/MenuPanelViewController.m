//
//  MenuPanelViewController.m
//  HarkPad
//
//  Created by Willem Bison on 10/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuPanelViewController.h"
#import "ProductCategory.h"
#import "Cache.h"

@implementation MenuPanelViewController
@synthesize categoryPanelView = _categoryPanelView;
@synthesize productPanelView = _productPanelView;
@synthesize categories = _categories;
@synthesize menuCard = _menuCard;
@synthesize delegate = _delegate;
@synthesize show = _show;


+ (MenuPanelViewController *) controllerWithMenuCard:(MenuCard *)menuCard menuPanelShow:(MenuPanelShow)show delegate:(id<ProductPanelDelegate>)delegate{
    MenuPanelViewController *controller = [[MenuPanelViewController alloc] init];
    controller.delegate = delegate;
    controller.menuCard = menuCard;
    controller.show = show;
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
    self.view = [MenuPanelView viewWithFrame:CGRectMake(0, 0, 100, 100) menuCard: self.menuCard menuPanelShow: _show delegate: _delegate];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
