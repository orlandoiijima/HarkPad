//
//  CompanyCell.h
//  HarkPad
//
//  Created by Willem Bison on 11/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Company.h"

@interface CompanyCell : UICollectionViewCell

@property (retain) IBOutlet UIImageView *logoView;
@property (retain) IBOutlet UIImageView *addView;
@property (retain) IBOutlet UILabel *nameLabel;
@property (retain) IBOutlet UILabel *cityLabel;
@property (retain) IBOutlet UIView *containerView;

@property(nonatomic, strong) Company * company;
@end
