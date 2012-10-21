//
//  CategorySupplementaryView.h
//  HarkPad
//
//  Created by Willem Bison on 10/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColorViewController.h"

@class ProductCategory;
@protocol MenuDelegate;
@class ColorButtonView;

@interface CategorySupplementaryView : UICollectionReusableView <ColorViewControllerDelegate>

@property (retain) IBOutlet UITextField *name;
@property (retain) IBOutlet ColorButtonView *colorButton;
@property(nonatomic, strong) id<MenuDelegate> delegate;

@property(nonatomic, strong) ProductCategory *category;

@property(nonatomic, strong) id x;

- (void)setupForCategory:(ProductCategory *)category delegate:(id <MenuDelegate>)delegate;

- (IBAction)textChange:(UITextField *)textField;


@end
