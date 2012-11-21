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
#import "CKCalendarViewController.h"
#import "UIBarButtonItem+Image.h"
#import "MenuCollectionView.h"
#import "ModalAlert.h"

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

#define EDITPANELWIDTH 300
#define SPACING 20

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
    _calendarButton = [UIBarButtonItem buttonWithImage:[UIImage imageNamed:@"calendar.png"] target:self action:@selector(getDate:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: doneButton, _calendarButton, _addButton, nil];

    _menuPanel = [MenuCollectionView viewWithFrame:CGRectMake(0, 0, self.view.frame.size.width - EDITPANELWIDTH - SPACING, self.view.frame.size.height) menuCard:_menuCard  menuPanelShow:MenuPanelShowAll numberOfColumns:4 editing:YES menuDelegate:self];
    [self.view addSubview:_menuPanel];

    _productProperties = [ProductPropertiesView viewWithFrame:CGRectMake(self.view.frame.size.width - EDITPANELWIDTH, 0, EDITPANELWIDTH, self.view.frame.size.height) menuCard:_menuCard];
    _productProperties.delegate = self;
    [self.view addSubview:_productProperties];

    UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    recognizer.delegate = self;
    [_menuPanel addGestureRecognizer: recognizer];

    for (int section=0; section < [_menuPanel numberOfSections]; section++) {
        if([_menuPanel numberOfItemsInSection:section] > 0) {
            [_menuPanel selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection: section] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            [_menuPanel collectionView:_menuPanel didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            break;
        }
    }
    [self updateTitle];
}

- (void)pinchHandler: (UIPinchGestureRecognizer *) pinchGestureRecognizer {
    if(pinchGestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;

    CGPoint point = [pinchGestureRecognizer locationInView: _menuPanel];
    int section = [_menuPanel sectionFromPoint:point];
    if (section == -1) return;
    if (pinchGestureRecognizer.scale <= 1)
        return;
    if (YES != [ModalAlert confirm:@"Sectie invoegen ?"])
        return;
    ProductCategory *newCategory = [[ProductCategory alloc] init];
    newCategory.name = NSLocalizedString(@"New category", nil);
    newCategory.type = CategoryTypeStandard;
    newCategory.color = [UIColor blueColor];
    [_menuPanel insertCategory: newCategory atIndex: section + 1];
    [self addProductInCategory:newCategory];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}


- (void) updateTitle {
    NSDateFormatter* shortDate = [[NSDateFormatter alloc] init];
    [shortDate setDateStyle:NSDateFormatterLongStyle];
    self.title = [NSString stringWithFormat: NSLocalizedString(@"Menu starting %@", nil), [shortDate stringFromDate: _menuCard.validFrom]];
}

- (void)didSelectProduct:(Product *)product {
    [self startEdit:product];
}

- (BOOL)canDeselect {
    if (_productProperties.product == nil)
        return YES;
    if ([_productProperties validate] == NO)
        return NO;
    return YES;
}

- (void)didSelectColor:(UIColor *)color forCategory:(ProductCategory *)category {
    int section = [_menuPanel sectionByCategory:category];
    [_menuPanel reloadSections:[NSIndexSet indexSetWithIndex: section]];
    _menuPanel.selectedItem = _menuPanel.selectedItem;
}

- (void)startEdit: (Product *)product {
    _productProperties.product = product;
}


- (void) save {
    [[Service getInstance]
            requestResource:@"menucard"
                         id:nil action:nil arguments:nil body:[_menuCard toDictionary]
                       verb:_menuCard.isNew ? HttpVerbPost : HttpVerbPut
                    success:^(ServiceResult *serviceResult) {

                    }
                      error:^(ServiceResult *serviceResult) {
                          [serviceResult displayError];
                      }
               progressInfo:[ProgressInfo progressWithHudText:NSLocalizedString(@"Saving...", nil) parentView:self.view]];
}

- (void)didTapDummyInCategory:(ProductCategory *)category {
    [self addProductInCategory:category];
}

- (void)addProductInCategory:(ProductCategory *)category {
    id item;
    if ([category.products count] > 0) {
        item = [[category.products objectAtIndex:0] copy];
        [item setValue:@"" forKey:@"name"];
    }
    else {
        item =  [[[item class] alloc] init];
    }
    [item setValue:NSLocalizedString(@"New", @"Key of new product") forKey:@"key"];
    [category.products addObject:item];

    [item setValue:category forKey:@"category"];

    int section = [_menuPanel sectionByCategory:category];
    int index = [category.products count] - 1;
    [_menuPanel insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:index inSection:section]]];
    _menuPanel.selectedItem = item;
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

- (void)didInclude:(id)item inFavorites:(bool)include {
    if (include == NO) {
        [_menuPanel removeFromFavorites:item];
    }
    else {
        [_menuPanel addToFavorites:item];
    }
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
