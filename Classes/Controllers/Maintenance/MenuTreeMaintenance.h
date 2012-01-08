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

@interface MenuTreeMaintenance : UIViewController <GridViewDataSource, ProductTreeViewDelegate, MenuTreeViewDelegate> {
    ProductTreeView *productView;
    MenuTreeView *menuView;
    Product * insertingProduct;
    CellPath *insertingStartPath;
}

@property (retain) ProductTreeView *productView;
@property (retain) MenuTreeView *menuView;
@property (retain) Product * insertingProduct;
@property (retain) CellPath *insertingStartPath;

- (void)productTreeView:(ProductTreeView *)productTreeView dragItem:(id)item atPoint: (CGPoint)point;
- (void) updateDataSource;

@end
