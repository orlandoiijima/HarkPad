//
//  ProductMaintenanceViewController.h
//  HarkPad
//
//  Created by Willem Bison on 13-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductPanelView.h"
#import "GridView.h"

@interface ProductMaintenanceViewController : UIViewController <UIScrollViewDelegate, GridViewDelegate, GridViewDataSource> {
    GridView *panelView;
    GridView *panelViewB;
    TreeNode *parentNode;
    TreeNode *rootNode;
}

@property (retain) IBOutlet GridView *panelView;
@property (retain) IBOutlet GridView *panelViewB;
@property (retain) IBOutlet UILabel *productLabel;
@property (retain) TreeNode *parentNode;
@property (retain) TreeNode *rootNode;


- (IBAction)addProduct:(id)sender;

@end
