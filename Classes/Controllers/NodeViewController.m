//
//  NodeViewController.m
//  HarkPad
//
//  Created by Willem Bison on 01/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeViewController.h"
#import "Utils.h"

@implementation NodeViewController

@synthesize uiName, node, delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNode:(TreeNode *)newNode delegate: (id<ItemPropertiesDelegate>) newDelegate {
    self = [super initWithNibName:@"NodeViewController" bundle:nil];

    self.node = newNode;
    self.delegate = newDelegate;

    return self;
}

- (bool)validate {
    if ([[Utils trim:uiName.text] length] == 0) {
        [uiName becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)saveAction {
    if ([self validate] == NO) return;

    node.name = [Utils trim:uiName.text];
    if([self.delegate respondsToSelector:@selector(didSaveItem:)])
        [self.delegate didSaveItem:node];
}

- (IBAction)cancelAction {
    if([self.delegate respondsToSelector:@selector(didCancelItem:)])
        [self.delegate didCancelItem:node];
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
    uiName.text = node.name;
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
