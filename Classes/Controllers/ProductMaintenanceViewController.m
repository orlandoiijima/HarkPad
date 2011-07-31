 //
//  ProductMaintenanceViewController.m
//  HarkPad
//
//  Created by Willem Bison on 13-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ProductMaintenanceViewController.h"
#import "ProductPanelView.h"
#import "Cache.h"
#import "GridView.h"
#import "Utils.h"
#import "Service.h"
#import "ProductPropertiesViewController.h"

@implementation ProductMaintenanceViewController

@synthesize panelView, parentNode, panelViewB, productLabel, rootNode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

#define MARGIN_LEFT 10
#define MARGIN_RIGHT 10
#define MARGIN_TOP 50
#define MARGIN_BOTTOM 10

#define COUNT_PANEL_COLUMNS 3

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    panelView.dataSource = self;
    panelView.delegate = self;
    panelView.leftHeaderWidth = 10;
    panelView.topHeaderHeight = 10;
    panelView.cellPadding = CGSizeMake(2, 2);
    parentNode = rootNode =	 [[Cache getInstance] tree];
    [panelView reloadData];
    [panelView setNeedsDisplay];
    
    panelViewB.dataSource = self;
    panelViewB.delegate = self;
    panelView.cellPadding = CGSizeMake(1, 1);
//    panelView.cellMargin = CGSizeMake(2, 2);
    [panelViewB reloadData];
}

- (NSUInteger) numberOfRowsInGridView:(GridView *)gridView
{
    int countButtons = [parentNode.nodes count];
    if(rootNode != parentNode)
        countButtons += 2;
    return (countButtons + 1) / COUNT_PANEL_COLUMNS;
}

- (NSUInteger) numberOfColumnsInGridView:(GridView *)gridView
{
    return COUNT_PANEL_COLUMNS;
}

- (NSUInteger) numberOfLinesInGridView:(GridView *)gridView column:(NSUInteger)column row:(NSUInteger)row
{
    return 1;
}

- (float) gridView:(GridView *)gridView heightForLineAtPath:(CellPath *)path
{
    return 30;
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

- (GridViewCellLine *) gridView:(GridView *)gridView cellLineForPath:(CellPath *)path
{
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

- (IBAction) popController
{
    [self.navigationController popViewControllerAnimated:YES];
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

 - (IBAction)addProduct:(id)sender {
     Product *product = [[[Product alloc] init] autorelease];
     ProductPropertiesViewController *controller = [[ProductPropertiesViewController alloc] initWithProduct:product];
     UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
     controller.popoverController = popover;
     [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
 }


 @end
