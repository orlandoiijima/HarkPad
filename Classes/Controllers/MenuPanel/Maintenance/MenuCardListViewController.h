//
//  MenuCardListViewController.h
//  HarkPad
//
//  Created by Willem Bison on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "CKCalendarView.h"

@interface MenuCardListViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) IBOutlet UICollectionView * menuList;
@property(nonatomic, strong) NSMutableArray *menuCards;

- (void) addNewMenuCard;

@end
