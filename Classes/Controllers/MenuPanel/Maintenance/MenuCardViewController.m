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

@interface MenuCardViewController ()

@end

@implementation MenuCardViewController
@synthesize menuPanel = _menuPanel;
@synthesize productProperties = _productProperties;
@synthesize menuCard = _menuCard;
@synthesize calendarButton = _calendarButton;
@synthesize menuProperties = _menuProperties;


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
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: doneButton, _calendarButton, nil];

    _menuPanel = [MenuPanelView viewWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height) menuCard:_menuCard menuPanelShow:MenuPanelShowAll delegate:self];
    [self.view addSubview:_menuPanel];

    _productProperties = [ProductPropertiesView viewWithFrame: CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, self.view.frame.size.height)];
    [self.view addSubview:_productProperties];

    _menuProperties = [MenuPropertiesView viewWithFrame: CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, self.view.frame.size.height) menuCard:_menuCard];
    [self.view addSubview:_menuProperties];

    [_menuPanel setMenuCard: _menuCard];

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

- (void)didTapCategory:(ProductCategory *)category {

    _menuPanel.selectedItem = [category.products objectAtIndex:0];
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
    [self endEdit];
    return YES;
}

- (void)startEdit: (Product *)product {
    if ([_menuPanel.selectedItem isKindOfClass:[Product class]]) {
        if (product == nil) return;
        if (_productProperties.product != nil) {
            [_productProperties.product removeObserver:_menuPanel forKeyPath:@"key"];
            [_productProperties.product.category removeObserver:_menuPanel forKeyPath:@"color"];
            [_productProperties.product.category removeObserver:_menuPanel forKeyPath:@"name"];
        }
        _productProperties.product = product;
        [product addObserver: _menuPanel forKeyPath:@"key" options:0 context:nil];
        [product.category addObserver: _menuPanel forKeyPath:@"color" options:0 context:nil];
        [product.category addObserver: _menuPanel forKeyPath:@"name" options:0 context:nil];
    }
}

- (void)endEdit {
    if ([_menuPanel.selectedItem isKindOfClass:[Product class]])
        [_productProperties endEdit];
}

- (void) save {
    [[Service getInstance]
            requestResource: @"menu"
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
               progressInfo: [ProgressInfo progressWithHudText:NSLocalizedString(@"Storing", nil) parentView:self.view]];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
