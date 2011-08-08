//
//  ProductPropertiesViewController.m
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ProductPropertiesViewController.h"
#import "Utils.h"
#import "Service.h"

@implementation ProductPropertiesViewController

@synthesize uiKey, uiName, uiPrice, uiCategory, uiVat, product, popoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithProduct:(Product *)newProduct {
    [super initWithNibName:@"ProductPropertiesViewController" bundle:nil];

    self.product = newProduct;

    return self;
}

- (bool)validate {
    if ([[Utils trim:uiKey.text] length] == 0) {
        [uiKey becomeFirstResponder];
        return NO;
    }
    if ([[Utils trim:uiName.text] length] == 0) {
        [uiName becomeFirstResponder];
        return NO;
    }
    if ([[Utils trim:uiPrice.text] length] == 0) {
        [uiPrice becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)saveAction {
    if ([self validate] == NO) return;

    product.name = [Utils trim:uiName.text];
    product.key = [Utils trim:uiKey.text];
    product.price = [Utils getAmountFromString:uiPrice.text];
    product.category = [self categoryByRow:[uiCategory selectedRowInComponent:0]];
    product.vat = uiVat.selectedSegmentIndex;
    if (product.id == 0)
        [[Service getInstance] createProduct:product delegate:nil callback:nil];
    else
        [[Service getInstance] updateProduct:product delegate:nil callback:nil];
    [popoverController dismissPopoverAnimated:YES];
}

- (ProductCategory *) categoryByRow: (int)row
{
    NSMutableArray *categories = [[[Cache getInstance] menuCard] categories];
    if (categories == nil || [categories count] <= row)
        return nil;
    return [categories objectAtIndex:row];        
}

- (int) rowByCategory: (ProductCategory *)searchCategory
{
    NSMutableArray *categories = [[[Cache getInstance] menuCard] categories];
    int row = 0;
    for (ProductCategory * category in categories) {
        if (category.id == searchCategory.id)
           return row;
        row++;
    }
    return 0;        
}

- (IBAction)cancelAction {
    [popoverController dismissPopoverAnimated:YES];
}

- (void)dealloc {
    [uiKey release];
    [uiName release];
    [uiPrice release];
    [uiCategory release];
    [uiVat release];
    [product release];
    [popoverController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    uiKey.text = product.key;
    uiName.text = product.name;
    uiPrice.text = [Utils getAmountString:product.price withCurrency:NO];
    uiVat.selectedSegmentIndex = (int)product.vat;
    [uiCategory selectRow:[self rowByCategory:product.category] inComponent:0 animated:YES];
    
    uiCategory.delegate = self;
    uiCategory.dataSource = self;

    self.contentSizeForViewInPopover = self.view.frame.size;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    ProductCategory *category = [self categoryByRow:row];
    if(category == nil) return @"";
    return category.name;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[[[Cache getInstance] menuCard] categories] count];
}


@end
