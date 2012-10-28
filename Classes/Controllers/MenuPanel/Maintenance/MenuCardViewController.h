//
//  MenuCard.h
//  HarkPad
//
//  Created by Willem Bison on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "ProductPanelView.h"
#import "CKCalendarView.h"
#import "MenuDelegate.h"
#import "ColorViewController.h"
#import "ItemPropertiesDelegate.h"
#import "LXReorderableCollectionViewFlowLayout.h"

@class ProductPropertiesView;
@class MenuPanelView;
@class MenuCard;
@class MenuPropertiesView;
@class MenuCollectionView;
@class ProductCategory;
@class CategorySupplementaryView;
@class QuickProductPropertiesController;

@interface MenuCardViewController : UIViewController <CKCalendarDelegate, MenuDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) IBOutlet MenuCollectionView *menuPanel;
@property(nonatomic, strong) IBOutlet ProductPropertiesView * productProperties;
@property(nonatomic, strong) MenuCard *menuCard;

@property(nonatomic, strong) UIPopoverController *popover;

@property(nonatomic, strong) UIBarButtonItem *calendarButton;

@property(nonatomic, strong) MenuPropertiesView * menuProperties;

@property(nonatomic, strong) UIBarButtonItem *addButton;

@property(nonatomic, strong) QuickProductPropertiesController *productPropertiesController;

+ (MenuCardViewController *)controllerWithMenuCard:(MenuCard *)card;

@end
