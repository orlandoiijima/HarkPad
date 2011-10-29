//
//  ProductListViewController.m
//  HarkPad
//
//  Created by Willem Bison on 13-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductListViewController.h"
#import "Cache.h"
#import "Utils.h"
#import "ProductDialogController.h"

@implementation ProductListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

  //  self.tableView.dataSource = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (ProductCategory *) categoryForSection: (int)section
{
    NSMutableArray *categories = [[[Cache getInstance] menuCard] categories];
    return [categories objectAtIndex:section];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[[Cache getInstance] menuCard] categories] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ProductCategory *category = [self categoryForSection:section];
    return [[category products] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ProductCategory *category = [self categoryForSection:section];
    return category.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }

    ProductCategory *category = [self categoryForSection:indexPath.section];
    Product *product = [[category products] objectAtIndex:indexPath.row];

    cell.textLabel.text = product.name;
    cell.detailTextLabel.text = product.isDeleted ? @"" : [Utils getAmountString:product.price withCurrency:YES];

    cell.textLabel.alpha = product.isDeleted ? 0.3 : 1;

    cell.textLabel.textColor = product.entityState == New || product.entityState == Modified ? [UIColor blueColor] : [UIColor blackColor];

    cell.showsReorderControl = product.isDeleted == NO;
    cell.shouldIndentWhileEditing = NO;
    return cell;
}

- (BOOL)tableView: (UITableView *)tableView canMoveRowAtIndexPath: (NSIndexPath *)indexPath {
    Product *product = [self productAtIndexPath:indexPath];
    return product != nil && product.isDeleted == false;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    Product *product = [self productAtIndexPath:sourceIndexPath];
    ProductCategory *category = [self categoryForSection:destinationIndexPath.section];
    if (product == nil || category == nil) return;
    [product.category.products removeObject:product];
    [category.products insertObject:product atIndex:destinationIndexPath.row];
    product.category = category;
    if (product.entityState != New)
        product.entityState = Modified;
}

- (Product *) productAtIndexPath: (NSIndexPath *) indexPath
{
    ProductCategory *category = [self categoryForSection:indexPath.section];
    Product *product = [[category products] objectAtIndex:indexPath.row];
    return product;
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    ProductCategory *category = [self categoryForSection:section];
//    return [[category products] count];
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    ProductCategory *category = [self categoryForSection:section];
//    return category.name;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
//    }
//
//    ProductCategory *category = [self categoryForSection:indexPath.section];
//    Product *product = [[category products] objectAtIndex:indexPath.row];
//
//    cell.textLabel.text = product.name;
//    cell.detailTextLabel.text = [Utils getAmountString:product.price withCurrency:YES];
//
//    return cell;
//}
//
///*
//// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//*/
//
///*
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }
//}
//*/
//
///*
//// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
//{
//}
//*/
//
///*
//// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the item to be re-orderable.
//    return YES;
//}
//*/
//
//- (Product *) productForIndexPath: (NSIndexPath *) indexPath
//{
//    ProductCategory *category = [self categoryForSection:indexPath.section];
//    Product *product = [[category products] objectAtIndex:indexPath.row];
//    return product;
//}

//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    Product *product = [self productForIndexPath:indexPath];
//    ProductDialogController *detailViewController = [[ProductDialogController alloc] initWithProduct: product];
//    [self.navigationController pushViewController:detailViewController animated:YES];
//}

@end
