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

@implementation MenuTreeView

@synthesize parentNode = _parentNode, rootNode, menuDelegate = _menuDelegate;

#define COUNT_PANEL_COLUMNS 3

- (void) initTreeView {
    self.delegate = self;
    self.dataSource = self;
    self.dropMode = DropModeInsertCell;

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
    int offset = path.row * COUNT_PANEL_COLUMNS + path.column;

    if(offset < [_parentNode.nodes count])
        return [_parentNode.nodes objectAtIndex:offset];
    return nil;
}


- (void)gridView:(GridView *)gridView didTapCellLine:(GridViewCellLine *)cellLine
{
    int offset = cellLine.path.row * COUNT_PANEL_COLUMNS + cellLine.path.column;

    if(offset < [_parentNode.nodes count]) {
        TreeNode *node = [_parentNode.nodes objectAtIndex:offset];
        if([node.nodes count] > 0) {
            self.parentNode = node;
        }
        else {
            if([self.menuDelegate respondsToSelector:@selector(menuTreeView: didTapProduct:)])
                [self.menuDelegate menuTreeView:self didTapProduct: node.product];
        }
    }
    else {
        if(offset == [_parentNode.nodes count]) {
            self.parentNode = _parentNode.parent;
        }

        self.parentNode = rootNode;
    }
    return;
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
    if(rootNode != _parentNode)
        countButtons += 2;
    return (countButtons + 1) / COUNT_PANEL_COLUMNS;
}

- (NSUInteger)numberOfColumnsInGridView:(GridView *)gridView {
    return COUNT_PANEL_COLUMNS;
}

- (NSUInteger)numberOfLinesInGridView:(GridView *)gridView column:(NSUInteger)column row:(NSUInteger)row {
    return 1;
}

- (GridViewCellLine *)gridView:(GridView *)gridView cellLineForPath:(CellPath *)path {
    if(path.row == -1 || path.column == -1) return nil;

    int offset = path.row * COUNT_PANEL_COLUMNS + path.column;
    if(offset < [_parentNode.nodes count])
    {
        TreeNode *node = [_parentNode.nodes objectAtIndex:offset];
        if(node.product != nil)
            return [[GridViewCellLine alloc] initWithTitle: node.product.key middleLabel: @"" bottomLabel: @"" backgroundColor: node.product.category.color path:path];
        else
            return [[GridViewCellLine alloc] initWithTitle: node.name middleLabel:@"" bottomLabel:@"" backgroundColor:[UIColor blueColor] path:path];
    }
    if(offset == [_parentNode.nodes count])
        return [[GridViewCellLine alloc] initWithTitle: NSLocalizedString(@"Back", nil) middleLabel:@"" bottomLabel:@""  backgroundColor:[UIColor blueColor] path:path];
    if(offset == [_parentNode.nodes count] + 1)
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

@end
