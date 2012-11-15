//
//  CategorySupplementaryView.h
//  HarkPad
//
//  Created by Willem Bison on 10/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColorViewController.h"
#import "TimeRangeDelegate.h"

@class ProductCategory;
@protocol MenuDelegate;
@class ColorButtonView;

@interface CategorySupplementaryView : UICollectionReusableView <ColorViewControllerDelegate, TimeRangeDelegate>

@property (retain) IBOutlet UITextField *name;
@property (retain) IBOutlet ColorButtonView *colorButton;
@property (retain) IBOutlet UIButton *foodButton;
@property (retain) IBOutlet UIButton *timeButton;
@property(nonatomic, strong) id<MenuDelegate> delegate;
@property(nonatomic, strong) ProductCategory *category;
@property(nonatomic, strong) UIPopoverController *popover;

- (void)setupForCategory:(ProductCategory *)category isEditing:(bool)isEditing delegate:(id <MenuDelegate>)delegate;

- (IBAction)textChange:(UITextField *)textField;
- (IBAction)toggleFood;
- (IBAction)getTimeRange;

@end
