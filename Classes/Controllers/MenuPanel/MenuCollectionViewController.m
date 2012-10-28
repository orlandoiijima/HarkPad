//
//  MenuCollectionViewController.m
//  HarkPad
//
//  Created by Willem Bison on 10/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuCollectionViewController.h"
#import "MenuCollectionView.h"
#import "MenuCard.h"

@interface MenuCollectionViewController ()

@end

@implementation MenuCollectionViewController


+ (MenuCollectionViewController *) controllerWithMenuCard:(MenuCard *)menuCard menuPanelShow:(MenuPanelShow)show delegate:(id<MenuDelegate>)delegate{
    MenuCollectionViewController *controller = [[MenuCollectionViewController alloc] init];
    controller.delegate = delegate;
    controller.menuCard = menuCard;
    controller.show = show;
    return controller;
}

- (MenuCollectionView *)menuCollectionView {
    return (MenuCollectionView *) self.view;
}

- (void) selectedItem:(id) item {
    self.menuCollectionView.selectedItem = item;
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
    [super loadView];
    self.view = [MenuCollectionView viewWithFrame:CGRectZero menuCard: _menuCard menuPanelShow: _show numberOfColumns:3 editing:NO menuDelegate: _delegate];
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
