//
//  MenuTreeViewController.h
//  HarkPad
//
//  Created by Willem Bison on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GridViewController.h"
#import "TreeNode.h"
#import "Product.h"

@class MenuTreeView;

@protocol MenuTreeViewDelegate <NSObject>

@optional
- (void) menuTreeView: (MenuTreeView *) menuTreeView didTapProduct: (Product *)product;
- (void) menuTreeView: (MenuTreeView *) menuTreeView didTapMenu: (Menu *)menu;
- (void) menuTreeView: (MenuTreeView *) menuTreeView didLongPressNode: (TreeNode *)node cellLine: (GridViewCellLine *)cellLine;
- (void) menuTreeView: (MenuTreeView *) menuTreeView didEndLongPressNode: (TreeNode *)node cellLine: (GridViewCellLine *)cellLine;
@end

@interface MenuTreeView : GridView <GridViewDelegate, UIScrollViewDelegate, GridViewDataSource> {
    TreeNode *_parentNode;
    TreeNode *_rootNode;
    id<MenuTreeViewDelegate> __strong _menuDelegate;
}

@property (retain, nonatomic) TreeNode *parentNode;
@property (retain) TreeNode *rootNode;
@property (retain) id<MenuTreeViewDelegate> menuDelegate;
@property NSUInteger countColumns;

- (TreeNode *)nodeAtCellLine: (GridViewCellLine *)cellLine;
- (TreeNode *)nodeAtPath: (CellPath *)path;
- (void) updateCellLinesByCategory: (ProductCategory *)productCategory;
- (void) updateCellLinesByProduct: (Product *)product;

@end
