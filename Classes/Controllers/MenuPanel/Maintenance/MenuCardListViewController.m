//
//  MenuCardListViewController.m
//  HarkPad
//
//  Created by Willem Bison on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuCardListViewController.h"
#import "Service.h"
#import "MenuCardViewController.h"
#import "MenuCardCell.h"
#import "NSDate-Utilities.h"
#import "GetDateViewController.h"
#import "CKCalendarView.h"

@interface MenuCardListViewController ()

@end

@implementation MenuCardListViewController
@synthesize menuList = _menuList;
@synthesize menuCards = _menuCards;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Menucards", nil);

    UINib *nib = [UINib nibWithNibName:@"MenuCardCell" bundle:[NSBundle mainBundle]];
    [_menuList registerNib:nib forCellWithReuseIdentifier:@"xjsjw"];

    // Do any additional setup after loading the view from its nib.
    [[Service getInstance]
            requestResource: @"menucard"
                         id: nil
                     action: nil
                  arguments: nil
                       body: nil
                     method: @"GET"
                    success: ^(ServiceResult *serviceResult) {
                                self.menuCards = [[NSMutableArray alloc] init];
                                MenuCard *dummyCard = [[MenuCard alloc] init];
                                [self.menuCards addObject: dummyCard];
                                for (NSMutableDictionary *dictionary in serviceResult.jsonData) {
                                    MenuCard *card = [MenuCard menuFromJson:dictionary];
                                    [self.menuCards addObject:card];
                                }
                                [_menuList reloadData];
                             }
                      error: ^(ServiceResult *serviceResult) {
                                [serviceResult displayError];
                             }
               progressInfo: [ProgressInfo progressWithHudText:NSLocalizedString(@"Loading...", nil) parentView:self.view]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MenuCard *menuCard = [self.menuCards objectAtIndex:indexPath.row];
    if (menuCard == nil)
        return nil;

    static NSString *cellIdentifier = @"xjsjw";

    MenuCardCell *cell = (MenuCardCell *) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setMenuCard:menuCard];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.menuCards count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
        [self addNewMenuCard];
    else {
        MenuCard *menuCard = [self.menuCards objectAtIndex:indexPath.row];
        MenuCardViewController *controller = [MenuCardViewController controllerWithMenuCard:menuCard];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void) addNewMenuCard {
    MenuCard *newCard = [[[Cache getInstance] menuCard] copy];
    newCard.entityState = EntityStateNew;
    newCard.id = -1;
    newCard.validFrom = [[NSDate date] dateByAddingDays:7];
    [self.menuCards insertObject:newCard atIndex:1];
    GetDateViewController *controller = [[GetDateViewController alloc] init];
    controller.menuCard = newCard;
    [self.navigationController pushViewController:controller animated:YES];
//    [_menuList insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem: 1 inSection: 0]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
