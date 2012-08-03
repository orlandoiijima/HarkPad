//
//  ProductsDialogController.m
//  HarkPad
//
//  Created by Willem Bison on 19-08-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ProductDialogController.h"
#import "QRootElement.h"
#import "QSection.h"
#import "QLabelElement.h"
#import "QBooleanElement.h"
#import "QEntryElement.h"
#import "QRadioElement.h"
#import "QDecimalElement.h"
#import "Cache.h"
#import "Service.h"

@implementation ProductDialogController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (ProductDialogController *) initWithProduct: (Product *) product
{
    QRootElement *form = [[QRootElement alloc] init];
    form.grouped = YES;
    QSection *section = [[QSection alloc] init];
    [form addSection: section];
    
    QEntryElement *key = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Code", nil) Value:product.key Placeholder:NSLocalizedString(@"Bestelpanel", nil)];
    key.key = @"Code";
    [section addElement:key];

    QEntryElement *name = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Naam", nil) Value:product.name Placeholder:NSLocalizedString(@"Bon, rekening", nil)];
    name.key = @"login";
    [section addElement:name];
    
    QDecimalElement *price = [[QDecimalElement alloc] initWithTitle:NSLocalizedString(@"Prijs", nil) value:[product.price floatValue]];
    price.fractionDigits = 2;
    price.key = @"price";
    [section addElement:price];
    
//	QBooleanElement *bool1 = [[QBooleanElement alloc] initWithTitle: NSLocalizedString(@"BTW Hoog", nil) BoolValue:product.vat == 1];
//    [section addElement:bool1];

    NSMutableArray *categories = [[NSMutableArray alloc] init];
    int i = 0, selected = 0;
    for (ProductCategory *category in [[[Cache getInstance] menuCard] categories]) {
        [categories addObject:category.name];
        if(category.id == product.category.id)
            selected = i;
        i++;
    }
    QRadioElement *category = [[QRadioElement alloc] initWithItems: categories selected:selected title: NSLocalizedString(@"Group", nil)];
	category.key = NSLocalizedString(@"Group", nil);
    [section addElement:category];
        
    QSection *propSection = [[QSection alloc] init];
    propSection.title = NSLocalizedString(@"Properties", nil);
    for (OrderLineProperty*productProperty in [[Cache getInstance] productProperties]) {
        QBooleanElement *property = [[QBooleanElement alloc] initWithTitle:productProperty.name BoolValue: [product hasProperty:productProperty.id]];
        property.onImage = [UIImage imageNamed:@"imgOn"];
        property.offImage = [UIImage imageNamed:@"imgOff"];
        [propSection addElement:property];
    }
    [form addSection:propSection];
    
    self.root = form;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action:@selector(cancel)] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target: self action:@selector(save)] ;
    return self;
}

- (void) cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) save
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [self.root fetchValueIntoObject:dict];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



- (void)viewDidLoad
{
    [super viewDidLoad];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
