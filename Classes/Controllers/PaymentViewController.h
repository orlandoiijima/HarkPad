//
//  PaymentViewController.h
//  HarkPad
//
//  Created by Willem Bison on 05-03-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Order.h"
#import "InvoiceDataSource.h"
#import "TableMapViewController.h"

@interface PaymentViewController : UIViewController {
    UITableView *orderTable; 
    UISegmentedControl *paymentType; 
    UIButton *goButton; 
    UILabel *nameLabel; 
    UILabel *tableLabel; 
    UILabel *amountLabel;     
}

@property (retain, nonatomic) Order *order; 

@property (retain) IBOutlet UITableView *orderTable; 
@property (retain) IBOutlet UISegmentedControl *paymentType; 
@property (retain) IBOutlet UIButton *goButton; 
@property (retain) IBOutlet UILabel *nameLabel; 
@property (retain) IBOutlet UILabel *tableLabel; 
@property (retain) IBOutlet UILabel *amountLabel; 
@property (retain) IBOutlet UIBarButtonItem *backButton; 
@property (retain) IBOutlet UISegmentedControl *groupingSegment; 
@property (retain) TableMapViewController *tableMapViewController;

@property (retain) InvoiceDataSource *dataSource;

- (IBAction) goPay;
- (IBAction) goBack;

- (IBAction) changeGrouping;

@end
