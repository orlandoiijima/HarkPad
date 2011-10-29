//
//  MenuTreeViewController.m
//  HarkPad
//
//  Created by Willem Bison on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuTreeViewController.h"
#import "Cache.h"
#import "Utils.h"
#import "GridViewController.h"
#import "GridView.h"

@implementation MenuTreeViewController

@synthesize parentNode, rootNode;

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


- (bool)gridView:(GridView *)gridView shouldSelectCellLine:(GridViewCellLine *)cellLine
{
    int offset = cellLine.path.row * COUNT_PANEL_COLUMNS + cellLine.path.column;

    if(offset < [parentNode.nodes count]) {
        TreeNode *node = [parentNode.nodes objectAtIndex:offset];
        if([node.nodes count] > 0) {
            parentNode = node;
            [gridView reloadData];
            return false;
        }
        return true;
    }

    if(offset == [parentNode.nodes count]) {
        parentNode = parentNode.parent;
        [gridView reloadData];
        return false;
    }

    parentNode = rootNode;
    [gridView reloadData];
    return false;
}

- (void)gridView:(GridView *)gridView startsDragWithCellLine:(GridViewCellLine *)cellLine
{
}

- (void)gridView:(GridView *)gridView didDeleteCellLine:(GridViewCellLine *)cellLine
{
    int offset = cellLine.path.row * COUNT_PANEL_COLUMNS + cellLine.path.column;

    if(offset >= [parentNode.nodes count])
        return;
    TreeNode *node = [parentNode.nodes objectAtIndex:offset];
    if(node == nil)
        return;
    [node.nodes removeObject:node];
}

- (NSUInteger)numberOfRowsInGridView:(GridView *)gridView {
    int countButtons = [parentNode.nodes count];
    if(rootNode != parentNode)
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
    if(offset < [parentNode.nodes count])
    {
        TreeNode *node = [parentNode.nodes objectAtIndex:offset];
        if(node.product != nil)
            return [[GridViewCellLine alloc] initWithTitle: node.product.key middleLabel:node.product.name bottomLabel: [Utils getAmountString: node.product.price withCurrency:YES] path:path];
        else
            return [[GridViewCellLine alloc] initWithTitle: node.name middleLabel:@"" bottomLabel:@"" path:path];
    }
    if(offset == [parentNode.nodes count])
        return [[GridViewCellLine alloc] initWithTitle: NSLocalizedString(@"Terug", nil) middleLabel:@"" bottomLabel:@""  path:path];
    if(offset == [parentNode.nodes count] + 1)
        return [[GridViewCellLine alloc] initWithTitle: NSLocalizedString(@"Home", nil) middleLabel:@"" bottomLabel:@""  path:path];
    return nil;
}

- (CGFloat)gridView:(GridView *)gridView heightForLineAtPath:(CellPath *)path {
    return 30;
}


#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gridView.dataSource = self;
    parentNode = rootNode =	 [[Cache getInstance] tree];
}


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
