//
//  MenuTreeMaintenance.m
//  HarkPad
//
//  Created by Willem Bison on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MenuTreeMaintenance.h"
#import "Cache.h"

@implementation MenuTreeMaintenance

@synthesize productView, menuView, insertingProduct, insertingStartPath;

#define COUNT_PANEL_COLUMNS 3

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.menuView = [[MenuTreeView alloc] init];
    [self.view addSubview: self.menuView];
    self.menuView.frame = CGRectMake(self.view.frame.origin.x, 44, self.view.frame.size.width/2, self.view.frame.size.height);
    self.menuView.leftHeaderWidth = 0;
    self.menuView.topHeaderHeight = 0;
    self.menuView.cellPadding = CGSizeMake(3, 3);

    self.menuView.dragMode = DragModeMove;
    [self.menuView reloadData];
    [self.menuView setNeedsDisplay];

    self.productView = [[ProductTreeView alloc] init];
    [self.view addSubview: self.productView];
    self.productView.frame = CGRectMake(
            self.view.frame.origin.x + menuView.frame.size.width,
            44,
            self.view.frame.size.width - menuView.frame.size.width,
            self.view.frame.size.height);
    self.productView.leftHeaderWidth = 0;
    self.productView.topHeaderHeight = 0;
    self.productView.cellPadding = CGSizeMake(3, 3);
    self.productView.productDelegate = self;
    self.productView.dragMode = DragModeCopy;

    [self.productView reloadData];
}

- (void)productTreeView:(ProductTreeView *)productTreeView dragItem:(id)item atPoint: (CGPoint)point {
    if (item == nil) return;
    CGPoint myPoint = [menuView convertPoint:point fromView:productTreeView];
    GridViewCellLine *targetCellLine = [menuView cellLineAtPoint:myPoint];
    if (targetCellLine == nil) return;
    if ([item isKindOfClass:[Product class]]) {
        if (productTreeView.dragCellLine.superview == menuView.contentView) {
            if(productTreeView.dragCellLine != targetCellLine) {
                [menuView swapCellLine: productTreeView.dragCellLine withCellLine:targetCellLine];
            }
        }
        else {
            self.insertingStartPath = [CellPath pathWithPath:targetCellLine.path];
            self.insertingProduct = item;
            CellPath *targetPath = [CellPath pathWithPath:targetCellLine.path];
            [menuView shiftCellsDown:targetCellLine.path];
            menuView.dragSteps = nil;
            [menuView storeDragStep:self.insertingStartPath];
            productTreeView.dragCellLine.path = targetPath;
            CGRect newFrame = [menuView.contentView convertRect:productTreeView.dragCellLine.frame fromView:productTreeView.contentView];
            [menuView.contentView addSubview: productTreeView.dragCellLine];
            productTreeView.dragCellLine.frame = newFrame;
        }
    }
    if ([item isKindOfClass:[ProductCategory class]]) {

    }
}

- (void)productTreeView:(ProductTreeView *)productTreeView didDropItem:(id)item atPoint: (CGPoint)point {
    if (item == nil) return;
    CGPoint myPoint = [menuView convertPoint:point fromView:productTreeView];
    GridViewCellLine *targetCellLine = [menuView cellLineAtPoint:myPoint];
    if (targetCellLine == nil) return;
    if ([item isKindOfClass:[Product class]]) {
        CellPath *targetPath = [CellPath pathWithPath:targetCellLine.path];
        [menuView moveCellLine:productTreeView.dragCellLine toPath:targetPath];
        [self updateDataSource];
    }
    if ([item isKindOfClass:[Product class]]) {

    }
}

- (void) updateDataSource
{
    TreeNode *node = [menuView nodeAtPath: insertingStartPath];
    if (node != nil) {
        TreeNode *newNode = [[TreeNode alloc] init];
        newNode.product = insertingProduct;
        int index = [node.parent.nodes indexOfObject:node];
        [node.parent.nodes insertObject:newNode atIndex:index];
    }
    for(int i = 1; i < [menuView.dragSteps count]; i++) {
        CellPath *fromPath = [menuView.dragSteps objectAtIndex:i-1];
        CellPath *toPath = [menuView.dragSteps objectAtIndex:i];
        TreeNode *fromNode = [menuView nodeAtPath:fromPath];
        TreeNode *toNode = [menuView nodeAtPath:toPath];
        int fromIndex = [node.parent.nodes indexOfObject: fromNode];
        int toIndex = [node.parent.nodes indexOfObject: toNode];
        [node.parent.nodes replaceObjectAtIndex:fromIndex withObject:toNode];
        [node.parent.nodes replaceObjectAtIndex:toIndex withObject:fromNode];
    }
}

//- (NSUInteger)numberOfRowsInGridView:(GridView *)gridView {
//    return 0;
//    //To change the template use AppCode | Preferences | File Templates.
//
//}
//
//- (NSUInteger)numberOfColumnsInGridView:(GridView *)gridView {
//    return 0;
//    //To change the template use AppCode | Preferences | File Templates.
//
//}
//
//- (NSUInteger)numberOfLinesInGridView:(GridView *)gridView column:(NSUInteger)column row:(NSUInteger)row {
//    return 0;
//    //To change the template use AppCode | Preferences | File Templates.
//
//}
//
//- (GridViewCellLine *)gridView:(GridView *)gridView cellLineForPath:(CellPath *)path {
//    return nil;
//    //To change the template use AppCode | Preferences | File Templates.
//
//}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
