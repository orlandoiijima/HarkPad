//
//  MenuTreeViewController.m
//  HarkPad
//
//  Created by Willem Bison on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MenuTreeView.h"
#import "Cache.h"
#import "ProductTreeView.h"
#import "MenuCard.h"
#import "Service.h"

@implementation ProductTreeView

@synthesize parentCategory = _parentCategory, productDelegate, dragItem;

#define COUNT_PANEL_COLUMNS 3

- (void) initTreeView {
    self.delegate = self;
    self.dataSource = self;
    self.parentCategory = nil;
    self.dropMode = DropModeNone;
    return;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initTreeView];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self initTreeView];

    }
    return self;
}

- (void) setParentCategory: (ProductCategory *)newParentCategory
{
    if (newParentCategory == _parentCategory)
        return;

    _parentCategory = newParentCategory;
    [self reloadData];
}


- (void)gridView:(GridView *)gridView didTapCellLine:(GridViewCellLine *)cellLine
{
    if (_parentCategory == nil) {
        int offset = cellLine.path.row * COUNT_PANEL_COLUMNS + cellLine.path.column;
        MenuCard *card = [[Cache getInstance] menuCard];
        if (offset < [card.categories count]) {
            self.parentCategory = [card.categories objectAtIndex:offset];
            return;
        }
    }
    self.parentCategory = nil;
    return;
}

- (void)gridView:(GridView *)gridView didLongPressCellLine:(GridViewCellLine *)cellLine {
    if (cellLine == nil) return;
    if([self.productDelegate respondsToSelector:@selector(productTreeView: didLongPressItem:cellLine:)])
        [self.productDelegate productTreeView:self didLongPressItem: [self itemForPath:cellLine.path] cellLine: cellLine];
}

- (void)gridView:(GridView *)gridView didDeleteCellLine:(GridViewCellLine *)cellLine
{
//    int offset = cellLine.path.row * COUNT_PANEL_COLUMNS + cellLine.path.column;
//
//    if(offset >= [_parentNode.nodes count])
//        return;
//    TreeNode *node = [_parentNode.nodes objectAtIndex:offset];
//    if(node == nil)
//        return;
//    [node.nodes removeObject:node];
}

- (NSUInteger)numberOfRowsInGridView:(GridView *)gridView {
    MenuCard *card = [[Cache getInstance] menuCard];
    int countButtons;
    if (_parentCategory == nil)
        countButtons = [card.categories count];
    else
        countButtons = [_parentCategory.products count] + 1;
    return ceil( (float)countButtons / COUNT_PANEL_COLUMNS);
}

- (NSUInteger)numberOfColumnsInGridView:(GridView *)gridView {
    return COUNT_PANEL_COLUMNS;
}

- (NSUInteger)numberOfLinesInGridView:(GridView *)gridView column:(NSUInteger)column row:(NSUInteger)row {
    return 1;
}

- (GridViewCellLine *)gridView:(GridView *)gridView cellLineForPath:(CellPath *)path {
    if(path.row == -1 || path.column == -1) return nil;

    MenuCard *card = [[Cache getInstance] menuCard];

    int offset = path.row * COUNT_PANEL_COLUMNS + path.column;
    if (_parentCategory == nil) {
        if (offset < [card.categories count]) {
            ProductCategory *category = [card.categories objectAtIndex:offset];
            return [[GridViewCellLine alloc] initWithTitle: category.name middleLabel: @"" bottomLabel: @"" backgroundColor: category.color path:path];
        }
    }
    else {
        if (offset < [_parentCategory.products count]) {
            Product *product = [_parentCategory.products objectAtIndex:offset];
            return [[GridViewCellLine alloc] initWithTitle: product.key middleLabel: @"" bottomLabel: @"" backgroundColor: _parentCategory.color path:path];
        }
        if (offset == [_parentCategory.products count]) {
            return [[GridViewCellLine alloc] initWithTitle: NSLocalizedString(@"Home", nil) middleLabel:@"" bottomLabel:@"" backgroundColor:[UIColor blueColor] path:path];
        }
    }
    return nil;
}

- (id)itemForPath: (CellPath *)path
{
    int offset = path.row * COUNT_PANEL_COLUMNS + path.column;
    if (_parentCategory == nil) {
        MenuCard *card = [[Cache getInstance] menuCard];
        if (offset < [card.categories count])
            return [card.categories objectAtIndex:offset];
        else
            return nil;
    }
    else {
        if (offset < [_parentCategory.products count])
            return [_parentCategory.products objectAtIndex:offset];
        else
            return nil;
    }
}

- (NSUInteger)gridView:(GridView *)gridView heightForLineAtPath:(CellPath *)path {
    return 50;
}

- (void)gridView:(GridView *)gridView startsDragWithCellLine:(GridViewCellLine *)cellLine
{
    self.dragItem = [self itemForPath:cellLine.path];
}

- (void)gridView:(GridView *)gridView movesDragWithCellLine:(GridViewCellLine *)cellLine atPoint: (CGPoint)point {
    if (cellLine == nil) return;
    if([self.productDelegate respondsToSelector:@selector(productTreeView: dragItem: atPoint:)])
        [self.productDelegate productTreeView:self dragItem: dragItem atPoint: point];
}


- (void)gridView:(GridView *)gridView endsDragWithCellLine:(GridViewCellLine *)cellLine atPoint: (CGPoint)point {
    if (cellLine == nil) return;
    if([self.productDelegate respondsToSelector:@selector(productTreeView: didDropItem: atPoint:)])
        [self.productDelegate productTreeView:self didDropItem: dragItem atPoint: point];
}

- (void) updateCellLinesByCategory: (ProductCategory *)productCategory
{
    if (_parentCategory != nil && _parentCategory.id != productCategory.id)
        return;
    for(GridViewCellLine *cellLine in [self.contentView subviews]) {
        if( [cellLine isKindOfClass:[GridViewCellLine class]] == false)
            continue;
        id item = [self itemForPath:cellLine.path];
        if (_parentCategory == nil) {
            if ( ((ProductCategory *)item).id == productCategory.id) {
                cellLine.backgroundColor = productCategory.color;
                cellLine.textLabel.text = productCategory.name;
            }
        }
        else {
            if ( ((Product *)item).category.id == productCategory.id)
                cellLine.backgroundColor = productCategory.color;
        }
    }
}

- (void) updateCellLinesByProduct: (Product *)updatedProduct
{
    if (updatedProduct == nil) return;
    if (_parentCategory == nil)
        return;
    if (_parentCategory.id != updatedProduct.category.id)
        return;
    for(GridViewCellLine *cellLine in [self.contentView subviews]) {
        if( [cellLine isKindOfClass:[GridViewCellLine class]] == false)
            continue;
        Product *product = (Product *)[self itemForPath:cellLine.path];
        if(product != nil && product.id == updatedProduct.id) {
            cellLine.textLabel.text = product.key;
        }
    }
}

//- (void)gridView:(GridView *)gridView willDisplayCellLine:(GridViewCellLine *)cell {
//    if (cell == nil)
//        return;
//    if (cell.isSelected) {
//        cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.7];
//        cell.textLabel.textColor = [UIColor whiteColor];
//    }
//    else {
//        TreeNode *node = [self nodeAtCellLine:cell];
//        if (node != nil && node.product != nil) {
//            cell.backgroundColor = node.product.category.color;
//            cell.textLabel.textColor = [UIColor blackColor];
//        }
//        else {
//            cell.backgroundColor = [UIColor blueColor];
//            cell.textLabel.textColor = [UIColor whiteColor];
//        }
//    }
//}

@end
