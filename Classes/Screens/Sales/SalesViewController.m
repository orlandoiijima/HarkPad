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
#import "NSDate-Utilities.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "TestFlight.h"

@implementation SalesViewController

@synthesize groupedTotals, dateToShow, dateLabel, tableAmounts;

#define COLUMN_WIDTH 75

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

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    float x = tableView.bounds.size.width - 4 * COLUMN_WIDTH - 55;
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, x, 20)];
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.text = [self keyForSection:section];
    [headerView addSubview:categoryLabel];
    if(section == 0) {
        NSArray *labels = [NSArray arrayWithObjects:@"Contant", @"Pin", @"Credit", @"Totaal", nil];
        for(int i=0; i < 4; i++) {
            UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, COLUMN_WIDTH, 20)];
            typeLabel.textAlignment = NSTextAlignmentRight;
            typeLabel.text = [labels objectAtIndex:i];
            typeLabel.backgroundColor = [UIColor clearColor];
            [headerView addSubview:typeLabel];
            x += COLUMN_WIDTH;
        }
    }
    return headerView;
}

- (NSString *) keyForSection: (int) section
{
    if(section > [groupedTotals count])
        return @"";
    NSArray* sortedKeys = [[groupedTotals allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return [sortedKeys objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    NSString *key = [self keyForSection:indexPath.section];
    ProductTotals *totals = [[groupedTotals objectForKey:key] objectAtIndex:indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        float x = tableView.bounds.size.width - 4 * COLUMN_WIDTH - 100;
        float y = 5;
        float height = cell.contentView.bounds.size.height - 10;
        for(int i=0; i < 3; i++) {
            UILabel *label = [self addAmountLabelWithFrame:CGRectMake(x, y, COLUMN_WIDTH, height) cell:cell];
            label.tag = 100 +i;
            x += COLUMN_WIDTH;
        }
        UILabel *label = [self addAmountLabelWithFrame:CGRectMake(x, y, COLUMN_WIDTH, height) cell:cell];
        label.tag = 200;
    }
    NSDecimalNumber *total = [NSDecimalNumber zero];
    for(int i=0; i < 3; i++) {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:100+i];
        NSDecimalNumber *amount = [totals.totals objectForKey:[NSString stringWithFormat:@"%d", i]];
        label.text = [Utils getAmountString: amount withCurrency:NO];
        label.backgroundColor = totals.product == nil ? [UIColor whiteColor] : totals.product.category.color;
        label.highlightedTextColor = [UIColor whiteColor];
        total = [total decimalNumberByAdding: amount];
    }
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:200];
    label.backgroundColor = totals.product == nil ? [UIColor whiteColor] : totals.product.category.color;
    label.shadowColor = [UIColor lightGrayColor];
    label.highlightedTextColor = [UIColor whiteColor];
    label.text = [Utils getAmountString: total withCurrency:NO];

   
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
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentRight;
    label.shadowColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:label];
    return label;
}

- (IBAction)printDayReport
{
//    [[Service getInstance] printSalesReport: dateToShow];
    [MBProgressHUD showSucceededAddedTo:self.view withText: NSLocalizedString(@"Report printed", nil)];
}

- (void) refreshView
{
    [MBProgressHUD showProgressAddedTo:self.view withText:NSLocalizedString(@"Loading...", nil)];
    [[Service getInstance] getSalesForDate:dateToShow
                                   success:^(ServiceResult *serviceResult) {
                                       NSMutableDictionary *sales = [[NSMutableDictionary alloc] init];
                                       NSMutableArray *stats = [[NSMutableArray alloc] init];
                                       for(NSDictionary *statDic in serviceResult.jsonData)
                                       {
                                           ProductTotals *totals = [ProductTotals totalsFromJsonDictionary: statDic];
                                           [stats addObject:totals];
                                       }
                                       [sales setObject: stats forKey: @"Sales"];
                                       serviceResult.jsonData = sales;
                                       [self refreshViewCallback:serviceResult];
                                   }
                                     error:^(ServiceResult *serviceResult) {
                                         [serviceResult displayError];
                                     }];
}

- (void) refreshViewCallback: (ServiceResult *)serviceResult
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if(serviceResult.isSuccess == false) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:serviceResult.error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [view show];
        return;
    }

    dateLabel.text = [dateToShow prettyDateString];

    NSMutableArray *productTotals = [serviceResult.data objectForKey: @"Sales"];

    self.groupedTotals = [[NSMutableDictionary alloc] init];
    if([productTotals count] == 0) {
        [tableAmounts reloadData];
        return;
    }
    NSMutableArray *categoryTotals = [[NSMutableArray alloc] init];
    [groupedTotals setObject: categoryTotals forKey:@"Totalen"];

    ProductTotals *grandTotalLine = [[ProductTotals alloc] init];
    grandTotalLine.product = nil;
    grandTotalLine.totals = [[NSMutableDictionary alloc] init];
    
    for(ProductTotals *total in productTotals) {
        NSString *key = [NSString stringWithFormat:@"%d.%@", total.product.category.sortOrder, total.product.category.name];
        NSMutableArray *totals = [groupedTotals objectForKey:key];
        if(totals == nil)
        {
            totals = [[NSMutableArray alloc] init];
            [groupedTotals setObject: totals forKey:key];
            
            ProductTotals *categoryLine = [[ProductTotals alloc] init];
            categoryLine.product = total.product;
            categoryLine.totals = [[NSMutableDictionary alloc] init];
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
    dateToShow = [dateToShow dateByAddingTimeInterval: interval]; 
    [self refreshView];
}

- (IBAction)handleDoubleTapGesture:(UITapGestureRecognizer *)sender
{
    dateToShow = [NSDate date]; 
    [self refreshView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [TestFlight passCheckpoint: [[self class] description]];
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

    tableAmounts.backgroundView = nil;

    dateToShow = [NSDate dateYesterday];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture];
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    
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
