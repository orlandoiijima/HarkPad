//
//  xMenuCardViewController.m
//  HarkPad
//
//  Created by Willem Bison on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CKCalendarView.h"
#import "MenuCardViewController.h"
#import "ProductPropertiesView.h"
#import "MenuPanelView.h"
#import "MenuCard.h"
#import "Service.h"
#import "CKCalendarView.h"
#import "CKCalendarViewController.h"
#import "UIBarButtonItem+Image.h"
#import "MenuPropertiesView.h"
#import "MenuCollectionView.h"
#import "UIColor-Expanded.h"
#import "ProductCategory.h"
#import "CategorySupplementaryView.h"

@interface MenuCardViewController ()

@end

@implementation MenuCardViewController
@synthesize menuPanel = _menuPanel;
@synthesize productProperties = _productProperties;
@synthesize menuCard = _menuCard;
@synthesize calendarButton = _calendarButton;
@synthesize menuProperties = _menuProperties;
@synthesize addButton = _addButton;


+ (MenuCardViewController *)controllerWithMenuCard:(MenuCard *)card {
    MenuCardViewController *controller = [[MenuCardViewController alloc] init];
    controller.menuCard = card;
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
    _calendarButton = [UIBarButtonItem buttonWithImage:[UIImage imageNamed:@"calendar.png"] target:self action:@selector(getDate:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: doneButton, _calendarButton, _addButton, nil];

    _menuPanel = [MenuCollectionView viewWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height) menuCard:_menuCard menuPanelShow:MenuPanelShowAll editing:YES delegate:self];
    [self.view addSubview:_menuPanel];

    _productProperties = [ProductPropertiesView viewWithFrame: CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, self.view.frame.size.height) menuCard:_menuCard];
    _productProperties.delegate = self;
    [self.view addSubview:_productProperties];

    _menuProperties = [MenuPropertiesView viewWithFrame: CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, self.view.frame.size.height) menuCard:_menuCard];
    _productProperties.delegate = self;
    [self.view addSubview:_menuProperties];

    [self updateTitle];
}

- (void) updateTitle {
    NSDateFormatter* shortDate = [[NSDateFormatter alloc] init];
    [shortDate setDateStyle:NSDateFormatterLongStyle];
    self.title = [NSString stringWithFormat: NSLocalizedString(@"Menu starting %@", nil), [shortDate stringFromDate: _menuCard.validFrom]];
}

- (void)didSelectProduct:(Product *)product {
    _productProperties.hidden = NO;
    _menuProperties.hidden = YES;
    [self startEdit:product];
}

- (void)didSelectMenu:(Menu *)menu {
    _productProperties.hidden = YES;
    _menuProperties.hidden = NO;
    _menuProperties.menu = menu;
}

- (BOOL)canDeselect {
    if (_productProperties.product == nil)
        return YES;
    if ([_productProperties validate] == NO)
        return NO;
    return YES;
}

- (void)didTapColorButtonOnHeaderView:(CategorySupplementaryView *)headerView {
    _activeHeaderView = headerView;
    ColorViewController *controller = [[ColorViewController alloc] init];
    controller.delegate = self;
    _popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    CGRect frame = [self.view convertRect:headerView.frame fromView:_menuPanel];
    [_popover presentPopoverFromRect: frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)colorPopoverControllerDidSelectColor:(NSString *)hexColor {
    ProductCategory *category = _activeHeaderView.category;
    category.color = [UIColor colorWithHexString:hexColor];
    int section = [_menuPanel sectionByCategory:category];
    [_menuPanel reloadSections:[NSIndexSet indexSetWithIndex: section]];
    [_popover dismissPopoverAnimated:YES];
}

- (void)startEdit: (Product *)product {
    if ([_menuPanel.selectedItem isKindOfClass:[Product class]]) {
        if (product == nil) return;
        _productProperties.product = product;
    }
}


- (void) save {
    [[Service getInstance]
            requestResource: @"menucard"
                         id: nil
                     action: nil
                  arguments: nil
                       body: [_menuCard toDictionary]
                     method: _menuCard.entityState == EntityStateNew ? @"POST" : @"PUT"
                    success: ^(ServiceResult *serviceResult){

                                }
                      error: ^(ServiceResult *serviceResult) {
                                  [serviceResult displayError];
                              }
               progressInfo: [ProgressInfo progressWithHudText:NSLocalizedString(@"Saving", nil) parentView:self.view]];
}

- (void)new {
    if ([_menuPanel.selectedItem isKindOfClass:[Product class]]) {
        Product *selectedProduct = (Product *)_menuPanel.selectedItem;
        Product *product = [[Product alloc] init];
        product.key = NSLocalizedString(@"New", @"Key of new product");
        product.category = selectedProduct.category;
        [product.category.products insertObject: product atIndex:0];
        [_menuPanel insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]]];
        _menuPanel.selectedItem = product;
    }
}

- (void)didTapDummyInCategory:(ProductCategory *)category {
    Product *product = [[Product alloc] init];
    product.key = NSLocalizedString(@"New", @"Key of new product");
    product.category = category;
    [product.category.products addObject: product];

    int section = [_menuPanel sectionByCategory:category];
    int item = [category.products count] - 1;
    [_menuPanel insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:item inSection:section]]];
    _menuPanel.selectedItem = product;
}

- (void) getDate:(UIBarButtonItem *)button {
    CKCalendarViewController *controller = [CKCalendarViewController controllerWithDate:_menuCard.validFrom delegate:self];
    _popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    [_popover presentPopoverFromBarButtonItem: _calendarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    _menuCard.validFrom = date;
    [_popover dismissPopoverAnimated:YES];
    [self updateTitle];
}

- (void)didModifyItem:(id)item {
    [_menuPanel refreshItem:item];
}

- (void)didDeleteItem:(id)item {
    [_menuPanel deleteItem:item];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
