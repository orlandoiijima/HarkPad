//
//  MenuCardCell.h
//  HarkPad
//
//  Created by Willem Bison on 10/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuCard.h"
#import "NSDate-Utilities.h"


@interface MenuCardCell : UICollectionViewCell

@property (retain) IBOutlet UILabel *dateLabel;
@property (retain) IBOutlet UILabel *countMenusLabel;
@property (retain) IBOutlet UILabel *countItemsLabel;

- (void)setMenuCard:(MenuCard *)menuCard;


@end
