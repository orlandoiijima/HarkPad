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

@synthesize uiKey, uiName, uiPrice, uiVat, product, delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithProduct:(Product *)newProduct delegate: (id<ItemPropertiesDelegate>) newDelegate {
    self = [super initWithNibName:@"ProductPropertiesViewController" bundle:nil];

    self.product = newProduct;
    self.delegate = newDelegate;

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
    product.vat = uiVat.selectedSegmentIndex;
    if([self.delegate respondsToSelector:@selector(didSaveItem:)])
        [self.delegate didSaveItem:product];
}

- (IBAction)cancelAction {
    if([self.delegate respondsToSelector:@selector(didCancelItem:)])
        [self.delegate didCancelItem:product];
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

@end
