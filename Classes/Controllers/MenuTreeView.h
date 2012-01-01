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
@end

@interface MenuTreeView : GridView <GridViewDelegate, UIScrollViewDelegate, GridViewDataSource> {
    TreeNode *_parentNode;
    TreeNode *_rootNode;
    id<MenuTreeViewDelegate> __strong _menuDelegate;
}

@property (retain, nonatomic) TreeNode *parentNode;
@property (retain) TreeNode *rootNode;
@property (retain) id<MenuTreeViewDelegate> menuDelegate;

@end
