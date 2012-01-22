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
#import "ProductTreeView.h"
#import "MenuTreeView.h"
#import "ItemPropertiesDelegate.h"

@interface MenuTreeMaintenance : UIViewController <GridViewDataSource, ProductTreeViewDelegate, MenuTreeViewDelegate, ItemPropertiesDelegate> {
    ProductTreeView *productView;
    MenuTreeView *menuView;
    Product * insertingProduct;
}

@property (retain) IBOutlet ProductTreeView *productView;
@property (retain) IBOutlet MenuTreeView *menuView;
@property (retain) Product * insertingProduct;
@property (retain, nonatomic) UIPopoverController *popoverController;
@property (retain) IBOutlet UIButton *addProductButton;
@property (retain) IBOutlet UIButton *addNodeButton;

- (void)productTreeView:(ProductTreeView *)productTreeView dragItem:(id)item atPoint: (CGPoint)point;
- (void) updateDataSourceWithCellLine: (GridViewCellLine *)cellLine;
- (void)presentPopoverWithProduct: (Product *)product fromRect: (CGRect)rect;
- (void)presentPopoverWithCategory: (ProductCategory *)category fromRect: (CGRect)rect;
- (void)presentPopoverWithNode: (TreeNode *)node fromRect: (CGRect)rect;

- (IBAction) addProductItem;
- (IBAction) addNodeItem;

@end
