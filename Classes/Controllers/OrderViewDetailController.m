//
//  OrderViewDetailController.m
//  HarkPad
//
//  Created by Willem Bison on 10-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "OrderViewDetailController.h"
#import "OrderLineDetailViewController.h"
#import "Service.h"
#import "OrderLineCell.h"
#import "OrderTableView.h"

@implementation OrderDetailViewController

@synthesize order;
@synthesize groupedOrderLines;
@synthesize tmpCell;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[OrderTableView alloc] initWithFrame:self.tableView.bounds style:UITableViewStyleGrouped];
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    ((UITableView *)self.view).editing = YES;
    ((UITableView *)self.view).allowsSelectionDuringEditing = YES;

}

- (id)initWithOrder:(Order *)initOrder {
    [super initWithStyle:UITableViewStyleGrouped];
    self.order = initOrder;
    return self;
}

- (void) setGroupedOrderLines: (NSMutableDictionary *) lines
{
    groupedOrderLines = lines;
    [(UITableView *)[self view] reloadData];
}


- (void) setOrderGrouping: (OrderGrouping) groupBy includeExisting: (BOOL) existing
{
    switch(groupBy)
    {
        case bySeat:
            groupedOrderLines = [order getBySeat:existing]; 
            break;
        case byCourse:
            groupedOrderLines = [order getByCourse:existing]; 
            break;
        case byCategory:
            groupedOrderLines = [order getByCategory:existing]; 
            break;
    }
    OrderTableView *tableView = (OrderTableView *)[self view];
    tableView.orderGrouping = groupBy;
    [tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(order == nil) return 0;
    OrderGrouping orderGrouping = [(OrderTableView *)[self tableView] orderGrouping];
    switch(orderGrouping)
    {
        case bySeat:
            return [order getLastSeat] + 2;
        case byCourse:
            return [order getLastCourse] + 2;
        default:
            return [groupedOrderLines count]; 
    }    

}

- (NSString *) keyForSection: (int)section
{
    OrderGrouping orderGrouping = [(OrderTableView *)[self tableView] orderGrouping];
    switch(orderGrouping)
    {
        case bySeat:
            return [order getSeatString:section];
        case byCourse:
            return [order getCourseString:section];
        default:
        {
            NSArray *sortedGroups = [[groupedOrderLines allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]; 
            return [sortedGroups objectAtIndex:section];
        }
    }    
}

- (OrderLine *) lineAtIndexPath : (NSIndexPath *) indexPath
{
    NSString *groupName = [self keyForSection:indexPath.section];
    NSMutableArray *group = [groupedOrderLines valueForKey:groupName];
    if(indexPath.row < [group count])
        return [group objectAtIndex:indexPath.row];
    else
        return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(order == nil) return 0;
    NSString *category = [self keyForSection:section];
    NSInteger c = [[groupedOrderLines valueForKey: category] count];
    return c == 0 ? 1 : c;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(order == nil) return 0;
    NSString *sectionHeader = [self keyForSection:section];
    return sectionHeader;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *group = [self keyForSection:indexPath.section];
    
    if([[groupedOrderLines valueForKey:group] count] == 0)
    {
        static NSString *cellId = @"noDataCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.textColor = [UIColor grayColor];
        }
        cell.textLabel.text = @"Empty !";
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    OrderLineCell *cell = (OrderLineCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OrderLineCell" owner:self options:nil] lastObject];
    }

    cell.shouldIndentWhileEditing = NO;
    OrderLine *line = [self lineAtIndexPath:indexPath];
    cell.orderLine = line;
    
    
//    if(line.product.properties.count > 0)
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.showsReorderControl = YES;
    
    return cell;
}

- (UIView *)tableView: (UITableView *)tableView viewForHeaderInSection:(NSInteger) section
{
    UIView *sectionView = [[UIView alloc] init];
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setTitle: @"+" forState:UIControlStateNormal];
//    button.titleLabel.textColor = [UIColor whiteColor];
    button.frame = CGRectMake(0,6,36,30);
    [sectionView addSubview: button];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(35,0, 100,40)];
    label.text = [self keyForSection: section];
    [sectionView addSubview:label];
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    return YES;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderLine *line = [self lineAtIndexPath:indexPath];
    return line.id == nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderLine *line = [self lineAtIndexPath:indexPath];
    if(line != nil)
        cell.backgroundColor = line.product.category.color;    
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {

    if(toIndexPath.row == fromIndexPath.row && toIndexPath.section == fromIndexPath.section)
        return;
    
    OrderLine *line = [self lineAtIndexPath:fromIndexPath];
    OrderGrouping orderGrouping = [(OrderTableView *)[self tableView] orderGrouping];
    switch(orderGrouping)
    {
        case bySeat:
            line.seat = toIndexPath.section;
            break;
        case byCourse:
            line.course = toIndexPath.section;
            break;
        default:
            return;
    }
    NSString *fromGroup = [self keyForSection:fromIndexPath.section];
    if([[groupedOrderLines valueForKey:fromGroup] count] > 0)
        [[groupedOrderLines valueForKey:fromGroup] removeObjectAtIndex:fromIndexPath.row];
    
    NSString *toGroup = [self keyForSection:toIndexPath.section];
    [[groupedOrderLines valueForKey:toGroup] insertObject:line atIndex:toIndexPath.row];
    
    [self performSelector:@selector(delayedReloadData:) withObject:tableView afterDelay:0];
//    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:fromIndexPath] withRowAnimation:YES];
//    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:toIndexPath] withRowAnimation:YES];
    
//    OrderLineCell *cell = (OrderLineCell *)[tableView cellForRowAtIndexPath:toIndexPath];
//    cell.orderLine = line;

 }

- (void)delayedReloadData:(UITableView *)tableView
{
    [tableView reloadData];
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderLine *orderLine = [self lineAtIndexPath:indexPath];
    OrderLineDetailViewController *detailViewController = [[OrderLineDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailViewController.orderLine = orderLine;
    detailViewController.controller = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: detailViewController];
    navController.title = orderLine.product.name;

    detailViewController.contentSizeForViewInPopover = CGSizeMake(300, 1);
    
    UIPopoverController *popOver = [[UIPopoverController alloc] initWithContentViewController:navController];
    popOver.delegate = self;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [popOver presentPopoverFromRect:cell.frame inView: tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    detailViewController.popoverContainer = popOver;
}


- (void) refreshSelectedCell
{
    //  [orderViewController.tableView reloadData];
    UITableView *tableView = (UITableView *)[self view];   
    NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
    OrderLineCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.orderLine = cell.orderLine;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

