//
//  PrinterListViewController.h
//  HarkPad
//
//  Created by Willem Bison on 11/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class ProgressInfo;

@interface PrinterListViewController : UIViewController <UICollectionViewDataSource, UITextFieldDelegate>

@property(nonatomic, strong) IBOutlet UICollectionView *printersView;
@property(nonatomic, strong) id printers;
@property(nonatomic, strong) ProgressInfo *progressInfo;
@end
