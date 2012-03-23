//
//  CategoryPropertiesViewController.m
//  HarkPad
//
//  Created by Willem Bison on 01/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoryPropertiesViewController.h"
#import "ItemPropertiesDelegate.h"
#import "Utils.h"

@implementation CategoryPropertiesViewController

@synthesize category, uiName, delegate, uiColorSliderPlaceHolder, uiColor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCategory:(ProductCategory *)newCategory delegate: (id<ItemPropertiesDelegate>) newDelegate {
    self = [super initWithNibName:@"CategoryPropertiesViewController" bundle:nil];

    self.category = newCategory;
    self.delegate = newDelegate;

    return self;
}

- (IBAction)saveAction {
    if ([self validate] == NO) return;

    category.name = [Utils trim:uiName.text];

    HRRGBColor rgbColor = [uiColor RGBColor];
    category.color = [UIColor colorWithRed:rgbColor.r green:rgbColor.g blue:rgbColor.b alpha:1.0f];
    if([self.delegate respondsToSelector:@selector(didSaveItem:)])
        [self.delegate didSaveItem: category];
}

- (bool)validate {
    if ([[Utils trim:uiName.text] length] == 0) {
        [uiName becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)cancelAction {
    if([self.delegate respondsToSelector:@selector(didCancelItem:)])
        [self.delegate didCancelItem: category];
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

    uiName.text = category.name;
    self.contentSizeForViewInPopover = self.view.frame.size;

    HRRGBColor rgbColor;
    RGBColorFromUIColor(category.color, &rgbColor);

    HRColorPickerStyle style;
    style = [HRColorPickerView fullColorStyle];

    self.uiColor = [[HRColorPickerView alloc] initWithStyle:style defaultColor:rgbColor];
    self.uiColor.backgroundColor = [UIColor whiteColor];
    self.uiColor.frame = self.uiColorSliderPlaceHolder.frame;
    [self.view addSubview: self.uiColor];
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
