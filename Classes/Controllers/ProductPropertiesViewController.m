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

@synthesize uiDescription, uiKey, uiName, uiPrice, uiCategory, product, popoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithProduct: (Product *)newProduct
{
    [super initWithNibName:@"ProductPropertiesViewController" bundle:nil];
    
    product = newProduct;
   
    return self;
}

- (bool) validate
{
    if([[Utils trim: uiKey.text] length] == 0) {
        [uiKey becomeFirstResponder];
        return NO;
    }
    if([[Utils trim: uiName.text] length] == 0) {
        [uiName becomeFirstResponder];
        return NO;
    }
    if([[Utils trim: uiPrice.text] length] == 0) {
        [uiPrice becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction) saveAction {
    if([self validate] == NO) return;
    
    product.name = [Utils trim: uiName.text];
    product.key = [Utils trim: uiKey.text];
    product.description = [Utils trim: uiDescription.text];
    product.price = [Utils getAmountFromString:uiPrice.text];
    
    if(product.id == 0)
        [[Service getInstance] createProduct:product delegate:nil callback:nil];
    else
        [[Service getInstance] updateProduct:product delegate:nil callback:nil];
    [popoverController dismissPopoverAnimated:YES];
}

- (IBAction) cancelAction {
    [popoverController dismissPopoverAnimated:YES];
}

- (IBAction) getCategoryAction {
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

    uiKey.text = product.key;
    uiName.text = product.name;
    uiPrice.text = [Utils getAmountString: product.price withCurrency: NO];
    uiDescription.text = product.description;
    uiCategory.titleLabel.text = product.category.name;
    
    self.contentSizeForViewInPopover = self.view.frame.size;
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
