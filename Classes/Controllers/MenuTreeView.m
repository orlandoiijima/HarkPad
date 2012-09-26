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
#import "Utils.h"
#import "GridViewController.h"
#import "GridView.h"
#import "TreeNode.h"
#import "Service.h"

@implementation MenuTreeView

@synthesize parentNode = _parentNode, rootNode, menuDelegate = _menuDelegate, countColumns;

- (void) initTreeView {
    self.delegate = self;
    self.dataSource = self;
    self.dropMode = DropModeInsertCell;
    self.countColumns = 3;

    self.parentNode = rootNode = [[Cache getInstance] tree];
//    [self reloadData];
//    [self setNeedsDisplay];
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

- (void) setParentNode: (TreeNode *)newParentNode
{
    if (newParentNode == _parentNode)
        return;

    _parentNode = newParentNode;
    [self reloadData];
}

- (TreeNode *)nodeAtCellLine: (GridViewCellLine *)cellLine {
    return [self nodeAtPath: cellLine.path];
}

- (TreeNode *)nodeAtPath: (CellPath *)path {
    int offset = path.row * countColumns + path.column;

    if(offset < [_parentNode.nodes count])
        return [_parentNode.nodes objectAtIndex:offset];
    return nil;
}


- (void)gridView:(GridView *)gridView didTapCellLine:(GridViewCellLine *)cellLine
{
    int offset = cellLine.path.row * countColumns + cellLine.path.column;

    if(offset < [_parentNode.nodes count]) {
        TreeNode *node = [_parentNode.nodes objectAtIndex:offset];
        if(node.menu) {
            if([self.menuDelegate respondsToSelector:@selector(menuTreeView: didTapMenu:)])
                [self.menuDelegate menuTreeView:self didTapMenu: node.menu];
        }
        else if(node.product) {
            if([self.menuDelegate respondsToSelector:@selector(menuTreeView: didTapProduct:)])
                [self.menuDelegate menuTreeView:self didTapProduct: node.product];
        }
        else {
            self.parentNode = node;
        }
    }
    else {
        if(offset == [_parentNode.nodes count]) {
            self.parentNode = _parentNode.parent;
        }
        else {
            self.parentNode = rootNode;
        }
    }
    return;
}

- (void)gridView:(GridView *)gridView didLongPressCellLine:(GridViewCellLine *)cellLine {
    TreeNode *node = [self nodeAtCellLine:cellLine];
    if([self.menuDelegate respondsToSelector:@selector(menuTreeView: didLongPressNode:cellLine:)])
        [self.menuDelegate menuTreeView:self didLongPressNode: node cellLine: cellLine];
}

- (void)gridView:(GridView *)gridView didEndLongPressCellLine:(GridViewCellLine *)cellLine {
    TreeNode *node = [self nodeAtCellLine:cellLine];
    if([self.menuDelegate respondsToSelector:@selector(menuTreeView: didEndLongPressNode:cellLine:)])
        [self.menuDelegate menuTreeView:self didEndLongPressNode: node cellLine: cellLine];
}

- (void)gridView:(GridView *)gridView startsDragWithCellLine:(GridViewCellLine *)cellLine
{
}


- (void)gridView:(GridView *)gridView didDeleteCellLine:(GridViewCellLine *)cellLine
{
    TreeNode *node = [self nodeAtCellLine:cellLine];
    if(node == nil)
        return;
    [node.nodes removeObject:node];
}

- (NSUInteger)numberOfRowsInGridView:(GridView *)gridView {
    int countButtons = [_parentNode.nodes count];
    if(_parentNode.parent != nil) {
        countButtons++;
        if(_parentNode.parent.parent != nil)
            countButtons++;
    }
    return floor(countButtons / countColumns) + 1;
}

- (NSUInteger)numberOfColumnsInGridView:(GridView *)gridView {
    return countColumns;
}

- (NSUInteger)numberOfLinesInGridView:(GridView *)gridView column:(NSUInteger)column row:(NSUInteger)row {
    return 1;
}

- (GridViewCellLine *)gridView:(GridView *)gridView cellLineForPath:(CellPath *)path {
    if(path.row == -1 || path.column == -1) return nil;

    int offset = path.row * countColumns + path.column;
    if(offset < [_parentNode.nodes count])
    {
        TreeNode *node = [_parentNode.nodes objectAtIndex:offset];
        if(node.product != nil)
            return [[GridViewCellLine alloc] initWithTitle: node.product.key middleLabel: @"" bottomLabel: @"" backgroundColor: node.product.category.color path:path];
        else
            return [[GridViewCellLine alloc] initWithTitle: node.name middleLabel:@"" bottomLabel:@"" backgroundColor:[UIColor blueColor] path:path];
    }
    if (_parentNode.parent == nil)
        return nil;
    if(offset == [_parentNode.nodes count])
        return [[GridViewCellLine alloc] initWithTitle: NSLocalizedString(@"Back", nil) middleLabel:@"" bottomLabel:@""  backgroundColor:[UIColor blueColor] path:path];
    if(offset == [_parentNode.nodes count] + 1 && _parentNode.parent.parent != nil)
        return [[GridViewCellLine alloc] initWithTitle: NSLocalizedString(@"Home", nil) middleLabel:@"" bottomLabel:@""  backgroundColor:[UIColor blueColor] path:path];
    return nil;
}

- (NSUInteger)gridView:(GridView *)gridView heightForLineAtPath:(CellPath *)path {
    return 50;
}

- (void)gridView:(GridView *)gridView willDisplayCellLine:(GridViewCellLine *)cell {
    if (cell == nil)
        return;
    if (cell.isSelected) {
        cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.7];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    else {
        TreeNode *node = [self nodeAtCellLine:cell];
        if (node != nil && node.product != nil) {
            cell.backgroundColor = node.product.category.color;
            cell.textLabel.textColor = [UIColor blackColor];
        }
        else {
            cell.backgroundColor = [UIColor blueColor];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
    }
}

- (void) updateCellLinesByCategory: (ProductCategory *)productCategory
{
    for(GridViewCellLine *cellLine in [self.contentView subviews]) {
        if( [cellLine isKindOfClass:[GridViewCellLine class]] == false)
            continue;
        TreeNode *node = [self nodeAtCellLine:cellLine];
        if (node != nil && node.product != nil) {
//            if (node.product.category.id == productCategory.id) {
//                cellLine.backgroundColor = productCategory.color;
//            }
        }
    }
}

- (void) updateCellLinesByProduct: (Product *)product
{
    for(GridViewCellLine *cellLine in [self.contentView subviews]) {
        if( [cellLine isKindOfClass:[GridViewCellLine class]] == false)
            continue;
        TreeNode *node = [self nodeAtCellLine:cellLine];
        if (node != nil && node.product != nil) {
            if (node.product.id == product.id) {
                cellLine.textLabel.text = product.key;
            }
        }
    }
}

@end