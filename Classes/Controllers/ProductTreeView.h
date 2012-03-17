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

@class ProductTreeView;

@protocol ProductTreeViewDelegate <NSObject>

@optional
- (void) productTreeView: (ProductTreeView *) productTreeView dragItem: (id)item atPoint: (CGPoint)point;
- (void) productTreeView: (ProductTreeView *) productTreeView didDropItem: (id)item atPoint: (CGPoint)point;
- (void) productTreeView: (ProductTreeView *) productTreeView didLongPressItem: (id)item cellLine: (GridViewCellLine *)cellLine;
@end


@interface ProductTreeView : GridView <GridViewDelegate, UIScrollViewDelegate, GridViewDataSource> {
    ProductCategory *parentCategory;
    id<ProductTreeViewDelegate> productDelegate;
}

@property (retain, nonatomic) ProductCategory *parentCategory;
@property (retain) id<ProductTreeViewDelegate> productDelegate;

@property (retain) id dragItem;

- (id)itemForPath: (CellPath *)path;
- (void) updateCellLinesByCategory: (ProductCategory *)productCategory;
- (void) updateCellLinesByProduct: (Product *)updatedProduct;

@end
