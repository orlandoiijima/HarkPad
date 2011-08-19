//
//  MenuTree.m
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "MenuTree.h"
#import "Cache.h"
#import "MenuItem.h"
#import "ProductPropertiesViewController.h"

@implementation MenuTree

@synthesize parentNode;

- (id)initWithStyle:(UITableViewStyle)style
{
    TreeNode *rootNode = [[Cache getInstance] tree];
    self = [self initWithStyle:style treeNode: rootNode];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style treeNode: (TreeNode *)node
{
    self = [super initWithStyle:style];
    if (self) {
        self.parentNode = node;
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
    if(parentNode == nil) {
        parentNode = [[Cache getInstance] tree];
    }
    [super viewDidLoad];

    self.title = parentNode.name;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 400, 44)];
    UIBarButtonItem *buttonDelete = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Verwijderen", nil) style:UIBarButtonItemStyleBordered target:self action:nil];
    UIBarButtonItem *buttonAddExisting = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Toevoegen", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(addExisting)];
    UIBarButtonItem *buttonAddNew = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Nieuw", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(addNew)];
    [toolbar setItems:[[NSArray alloc] initWithObjects:buttonDelete, buttonAddExisting, buttonAddNew, nil] animated:YES];
    self.navigationItem.titleView = toolbar;
}

- (void) addNew
{
    Product *product = [[[Cache getInstance] menuCard] getProduct:10];
    ProductPropertiesViewController *vc = [[ProductPropertiesViewController alloc] initWithProduct: product];
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
    popoverController.delegate = self;
    vc.popoverController = popoverController;
    [popoverController presentPopoverFromRect:self.view.frame inView: self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];    
}

- (void) addExisting
{
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(parentNode == nil) return 0;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(parentNode == nil) return 0;
    if(parentNode.menu != nil)
        return [parentNode.menu.items count];
    return [parentNode.nodes count];
}

- (id)itemAtIndexPath: (NSIndexPath *)indexPath
{
    if(parentNode.menu != nil)
        return [parentNode.menu.items objectAtIndex:indexPath.row];
    else
        return [parentNode.nodes objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    id item = [self itemAtIndexPath: indexPath];
    
    if(parentNode.menu != nil) {
        MenuItem *menuItem = (MenuItem *)item;
        cell.backgroundColor = menuItem.product.category.color;
        cell.textLabel.text = menuItem.product.name;
        cell.detailTextLabel.text = menuItem.product.key;
    }
    else {
        TreeNode *node = (TreeNode *)item;
        if(node.product != nil) {
            cell.backgroundColor = node.product.category.color;
            cell.textLabel.text = node.product.name;
            cell.detailTextLabel.text = node.product.key;
        }
        else
            if(node.menu != nil) {
                cell.backgroundColor = [UIColor redColor];
                cell.textLabel.text = node.menu.name;
                cell.detailTextLabel.text = @"Menu";
            }
            else {
                cell.backgroundColor = [UIColor blueColor];
                cell.textLabel.text = node.name;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemAtIndexPath: indexPath];
    if([item isKindOfClass:[MenuItem class]]) {
        MenuItem *menuItem = (MenuItem *)item;
        [cell setBackgroundColor:menuItem.product.category.color];
    }
    else {
        TreeNode *node = (TreeNode *)item;
        if(node.product != nil) {
            [cell setBackgroundColor: node.product.category.color];
        }
        else 
        if(node.menu != nil) {
            [cell setBackgroundColor:[UIColor redColor]];
        }
        else {
            [cell setBackgroundColor: [UIColor blueColor]];
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TreeNode *node = (TreeNode *)[self itemAtIndexPath: indexPath];
    if([node isKindOfClass:[TreeNode class]] == false) return;
    if(node.product != nil) return;
    MenuTree *detailViewController = [[MenuTree alloc] initWithStyle:UITableViewStylePlain treeNode:node];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
