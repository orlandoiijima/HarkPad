//
//  PrinterCell.h
//  HarkPad
//
//  Created by Willem Bison on 11/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class PrinterInfo;
@class PrinterListViewController;

@interface PrinterCell : UICollectionViewCell

@property(retain) IBOutlet UILabel *ip;
@property(retain) IBOutlet UITextField *name;
@property(retain) IBOutlet UILabel *status;
@property (retain) IBOutlet UIImageView *statusImage;
@property (retain) IBOutlet UIImageView *printerImage;

@property(nonatomic) BOOL isOnline;

- (void)setPrinter:(PrinterInfo *)printerInfo delegate:(id)delegate;

@end
