//
//  CategorySupplementaryView.h
//  HarkPad
//
//  Created by Willem Bison on 10/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class ProductCategory;
@protocol MenuDelegate;

@interface CategorySupplementaryView : UICollectionReusableView

@property (retain) IBOutlet UITextField *name;
@property (retain) IBOutlet UIButton *colorButton;
@property(nonatomic, strong) id<MenuDelegate> delegate;

@property(nonatomic, strong) ProductCategory *category;

@property(nonatomic, strong) id x;

- (void)setupForCategory:(ProductCategory *)category delegate:(id <MenuDelegate>)delegate;

- (IBAction) colorButtonTap;

- (IBAction)textChange:(UITextField *)textField;


@end
