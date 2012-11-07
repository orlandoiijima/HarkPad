//
//  PrinterListViewController.h
//  HarkPad
//
//  Created by Willem Bison on 11/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@interface PrinterListViewController : UIViewController <UICollectionViewDataSource, UITextFieldDelegate>

@property(nonatomic, strong) UICollectionView *printersView;
@property(nonatomic, strong) id printers;
@end
