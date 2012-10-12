//
//  MenuCardListViewController.h
//  HarkPad
//
//  Created by Willem Bison on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@interface MenuCardListViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) IBOutlet UICollectionView * menuList;
@property(nonatomic, strong) IBOutlet UIButton * buttonNew;
@property(nonatomic, strong) NSMutableArray *menuCards;

- (IBAction) new;

@end
