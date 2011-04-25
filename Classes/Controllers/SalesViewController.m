//
//  SalesViewController.m
//  HarkPad
//
//  Created by Willem Bison on 09-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "SalesViewController.h"
#import "Service.h"
#import "ProductTotals.h"

@implementation SalesViewController

@synthesize groupedTotals, dateToShow, dateLabel, tableAmounts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [groupedTotals count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self keyForSection:section];
    return [[groupedTotals objectForKey:key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self keyForSection:section];
}

- (NSString *) keyForSection: (int) section
{
    if(section > [groupedTotals count])
        return @"";
    NSArray* sortedKeys = [[groupedTotals allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedKeys objectAtIndex:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    NSString *key = [self keyForSection:indexPath.section];
    ProductTotals *totals = [[groupedTotals objectForKey:key] objectAtIndex:indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        float width = 75;
        float x = tableView.bounds.size.width - 4 * width - 100;
        float y = 5;
        float height = cell.contentView.bounds.size.height - 10;
        for(int i=0; i < 3; i++) {
            UILabel *label = [self addAmountLabelWithFrame:CGRectMake(x, y, width, height) cell:cell];
            label.tag = 100 +i;
            x += width;
        }
        UILabel *label = [self addAmountLabelWithFrame:CGRectMake(x, y, width, height) cell:cell];
        label.tag = 200;
    }
    float total = 0;
    for(int i=0; i < 3; i++) {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:100+i];
        NSDecimalNumber *amount = [totals.totals objectForKey:[NSString stringWithFormat:@"%d", i]];
        label.text = [NSString stringWithFormat:@"%.02f", [amount floatValue]];
        label.backgroundColor = totals.product == nil ? [UIColor whiteColor] : totals.product.category.color;
        label.highlightedTextColor = [UIColor whiteColor];
        total += [amount floatValue];
    }
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:200];
    label.backgroundColor = totals.product == nil ? [UIColor whiteColor] : totals.product.category.color;
    label.shadowColor = [UIColor lightGrayColor];
    label.highlightedTextColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%.02f", total];

   
    if([key isEqualToString:@"Totalen"]) {
        cell.textLabel.text = totals.product == nil ? @"Totaal" : totals.product.category.name;
        cell.backgroundColor = totals.product == nil ? [UIColor whiteColor] : totals.product.category.color;
    }
    else {
        cell.textLabel.text = totals.product.key;
        cell.backgroundColor = totals.product.category.color;
    }
    cell.textLabel.shadowColor = [UIColor lightGrayColor];

    return cell;
}

- (UILabel *) addAmountLabelWithFrame: (CGRect) frame  cell: (UITableViewCell *)cell
{
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.textAlignment = UITextAlignmentRight;
    label.shadowColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:label];
    return label;
}

- (IBAction)printDayReport
{
    [[Service getInstance] printSalesReport:[NSDate date]];
}

- (void) refreshView
{
    dateLabel.text = [dateToShow prettyDateString];

    // Do any additional setup after loading the view from its nib.
    NSMutableArray *productTotals = [[Service getInstance] getSalesStatistics:dateToShow];
    
    self.groupedTotals = [[[NSMutableDictionary alloc] init] autorelease];
    if([productTotals count] == 0) {
        [tableAmounts reloadData];
        return;
    }
    NSMutableArray *categoryTotals = [[[NSMutableArray alloc] init] autorelease];
    [groupedTotals setObject: categoryTotals forKey:@"Totalen"];

    ProductTotals *grandTotalLine = [[[ProductTotals alloc] init] autorelease];
    grandTotalLine.product = nil;
    grandTotalLine.totals = [[[NSMutableDictionary alloc] init] autorelease];
    
    for(ProductTotals *total in productTotals) {
        NSString *key = [NSString stringWithFormat:@"%d.%@", total.product.category.sortOrder, total.product.category.name];
        NSMutableArray *totals = [groupedTotals objectForKey:key];
        if(totals == nil)
        {
            totals = [[[NSMutableArray alloc] init] autorelease];
            [groupedTotals setObject: totals forKey:key];
            
            ProductTotals *categoryLine = [[[ProductTotals alloc] init] autorelease];
            categoryLine.product = total.product;
            categoryLine.totals = [[[NSMutableDictionary alloc] init] autorelease];
            [categoryTotals addObject: categoryLine];
        }
        [totals addObject:total];
        
        for(ProductTotals *categoryLine in categoryTotals)
        {
            if(categoryLine.product.category.id == total.product.category.id)
            {
                for(NSString *key in [total.totals allKeys])
                {
                    float amount = [[categoryLine.totals objectForKey:key] floatValue];
                    amount += [[total.totals objectForKey:key] floatValue];
                    [categoryLine.totals setObject:[NSDecimalNumber numberWithFloat:amount] forKey:key];

                    amount = [[grandTotalLine.totals objectForKey:key] floatValue];
                    amount += [[total.totals objectForKey:key] floatValue];
                    [grandTotalLine.totals setObject:[NSDecimalNumber numberWithFloat:amount] forKey:key];
                }
                break;
            }
        }
    }
    [categoryTotals addObject: grandTotalLine];
    [tableAmounts reloadData];
}

- (IBAction)handleSwipeGesture:(UISwipeGestureRecognizer *)sender
{
    int interval = sender.direction == UISwipeGestureRecognizerDirectionLeft ? 24*60*60 : -24*60*60;
    dateToShow = [[dateToShow dateByAddingTimeInterval: interval] retain]; 
    [self refreshView];
}

- (IBAction)handleDoubleTapGesture:(UITapGestureRecognizer *)sender
{
    dateToShow = [[NSDate date] retain]; 
    [self refreshView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshView];	
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dateToShow = [[NSDate date] retain];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture];
    [swipeGesture release];   
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
    [swipeGesture release];   
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture release];   
    
    [self refreshView];
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