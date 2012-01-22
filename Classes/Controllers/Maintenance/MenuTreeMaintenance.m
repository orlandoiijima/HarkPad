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
#import "Service.h"
#import "ProductPropertiesViewController.h"
#import "CategoryPropertiesViewController.h"
#import "NodeViewController.h"

@implementation MenuTreeMaintenance

@synthesize productView, menuView, insertingProduct, popoverController, addProductButton, addNodeButton;

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
    
    self.menuView.frame = CGRectMake(self.view.frame.origin.x, 60, self.view.frame.size.width/2, self.view.frame.size.height);
    self.menuView.leftHeaderWidth = 0;
    self.menuView.topHeaderHeight = 0;
    self.menuView.cellPadding = CGSizeMake(3, 3);
    self.menuView.menuDelegate = self;

    self.menuView.dragMode = DragModeMove;
    [self.menuView reloadData];
    [self.menuView setNeedsDisplay];

//    self.productView = [[ProductTreeView alloc] init];
//    [self.view addSubview: self.productView];
    self.productView.frame = CGRectMake(
            self.view.frame.origin.x + menuView.frame.size.width,
            60,
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
            self.insertingProduct = item;
            CellPath *targetPath = [CellPath pathWithPath:targetCellLine.path];
            [menuView shiftDownFrom:targetCellLine.path to: nil];
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
        [self updateDataSourceWithCellLine: productTreeView.dragCellLine];
    }
    if ([item isKindOfClass:[Product class]]) {

    }
}

- (void) updateDataSourceWithCellLine: (GridViewCellLine *)cellLine
{
    NSUInteger offset = (NSUInteger) [menuView toOffset:cellLine.path];
    if (insertingProduct != nil) {
        TreeNode *newNode = [[TreeNode alloc] init];
        newNode.product = insertingProduct;
        newNode.parent = menuView.parentNode;
        [newNode.parent.nodes insertObject:newNode atIndex: offset];
        [[Service getInstance] createTreeNode:newNode delegate:nil callback:nil];

        insertingProduct = nil;
    }
    else {
        TreeNode *node = [menuView nodeAtPath: menuView.dragStartPath];
        if (node == nil) return;
        [node.parent.nodes removeObjectAtIndex: [menuView toOffset:menuView.dragStartPath]];
        [node.parent.nodes insertObject:node atIndex:[menuView toOffset:cellLine.path]];
        [[Service getInstance] updateTreeNode: node delegate:nil callback:nil];
        
    }
}

- (void)didSaveItem:(id)item {
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
    
    if ([item isKindOfClass:[Product class]]) {
        Product *product = (Product *)item;
        if (product == nil) return;
        if (product.id == 0)
            [[Service getInstance] createProduct:product delegate:nil callback:nil];
        else {
            [[Service getInstance] updateProduct:product delegate:nil callback:nil];
            [productView updateCellLinesByProduct:product];
            [menuView updateCellLinesByProduct:product];
        }
    }
    if ([item isKindOfClass:[ProductCategory class]]) {
        ProductCategory *category = (ProductCategory *)item;
        if (category == nil) return;
        if (category.id == 0)
            [[Service getInstance] createCategory:category delegate:nil callback:nil];
        else {
            [[Service getInstance] updateCategory:category delegate:nil callback:nil];
            [menuView updateCellLinesByCategory:category];
            [productView updateCellLinesByCategory:category];
        }
    }
    if ([item isKindOfClass:[TreeNode class]]) {
        TreeNode *node = (TreeNode *)item;
        if (node == nil) return;
        if (node.id == 0)
            [[Service getInstance] createTreeNode: node delegate:nil callback:nil];
        else {
            [[Service getInstance] updateTreeNode:node delegate:nil callback:nil];
        }
    }
}

- (void)didCancelItem:(id)item {
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
}

- (IBAction) addNodeItem
{
    if (self.popoverController != nil) return;
    TreeNode *newNode = [[TreeNode alloc] init];
    newNode.name = NSLocalizedString(@"Submenu", nil);
    newNode.parent = menuView.parentNode;
    [self presentPopoverWithNode: newNode fromRect: addNodeButton.frame];
}

- (IBAction) addProductItem
{
    if (self.popoverController != nil) return;
    if (productView.parentCategory == nil) {
        ProductCategory *category = [[ProductCategory alloc] init];
        [self presentPopoverWithCategory:category fromRect: addProductButton.frame];
    }
    else {
        Product *product = [[Product alloc] init];
        product.category = productView.parentCategory;
        [self presentPopoverWithProduct:product fromRect: addProductButton.frame];
    }
}

- (void)menuTreeView:(MenuTreeView *)menuTreeView didLongPressNode:(TreeNode *)node cellLine: (GridViewCellLine *)cellLine {
    if (self.popoverController != nil) return;
    if (node == nil) return;
    [self presentPopoverWithNode:node fromRect: [self.view convertRect:cellLine.frame fromView: menuTreeView]];
}

- (void)presentPopoverWithNode: (TreeNode *)node fromRect: (CGRect)rect
{
    NodeViewController *controller = [[NodeViewController alloc] initWithNode: node delegate:self];
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    [self.popoverController presentPopoverFromRect: rect inView: self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)productTreeView:(ProductTreeView *)productTreeView didLongPressItem:(id)item cellLine: (GridViewCellLine *)cellLine {
    if (self.popoverController != nil) return;
    if (item == nil) return;
    if ([item isKindOfClass:[Product class]]) {
        Product *product = (Product *)item;
        [self presentPopoverWithProduct:product fromRect: [self.view convertRect:cellLine.frame fromView: productTreeView]];
    }
    if ([item isKindOfClass:[ProductCategory class]]) {
        ProductCategory *category = (ProductCategory *)item;
        [self presentPopoverWithCategory:category fromRect: [self.view convertRect:cellLine.frame fromView: productTreeView]];
    }
}

- (void)presentPopoverWithProduct: (Product *)product fromRect: (CGRect)rect
{
    ProductPropertiesViewController *controller = [[ProductPropertiesViewController alloc] initWithProduct: product delegate:self];
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    [self.popoverController presentPopoverFromRect: rect inView: self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)presentPopoverWithCategory: (ProductCategory *)category fromRect: (CGRect)rect
{
    CategoryPropertiesViewController *controller = [[CategoryPropertiesViewController alloc] initWithCategory: category delegate:self];
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    [self.popoverController presentPopoverFromRect: rect inView: self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)menuTreeView:(MenuTreeView *)menuTreeView didLongPressNode:(TreeNode *)node {
    if (node == nil) return;
    if (node.menu != nil || node.product != nil) return;
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
