//
//  MenuTreeMaintenance.h
//  HarkPad
//
//  Created by Willem Bison on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GridView.h"
#import "GridViewController.h"
#import "TreeNode.h"

@class ProductListViewController;
@class MenuTreeViewController;

@interface MenuTreeMaintenance : UIViewController <GridViewDataSource> {
//    GridView *menuView;
    MenuTreeViewController *menuViewController;
//    UITableView *productView;
    ProductListViewController *productViewController;

}

@property (retain) MenuTreeViewController *menuViewController;
@property (retain) ProductListViewController *productViewController;

@end
