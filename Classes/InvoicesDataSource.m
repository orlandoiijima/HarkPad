//
//  InvoicesDataSource.m
//  HarkPad
//
//  Created by Willem Bison on 20-05-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "InvoicesDataSource.h"
#import "Service.h"
#import "Invoice.h"

@implementation InvoicesDataSource

@synthesize invoices;

+ (InvoicesDataSource *) dataSource
{
    InvoicesDataSource *source = [[InvoicesDataSource alloc] init];
    source.invoices = [[Service getInstance] getInvoices];
    return source;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section  != 0) return 0;
    return [invoices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if(indexPath.row < [invoices count]) {
        Invoice *invoice = [invoices objectAtIndex:indexPath.row];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        
        cell.textLabel.text = [NSString stringWithFormat:@"Tafel %@ (%@)", invoice.table.name, [formatter stringFromDate:invoice.createdOn]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"€ %.02f", [invoice.amount doubleValue]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if(invoice.paymentType == -1)
            cell.textLabel.textColor = [UIColor redColor];
    }
    return cell;
}

@end
