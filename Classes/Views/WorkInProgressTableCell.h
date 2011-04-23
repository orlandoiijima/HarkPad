//
//  WorkInProgressTableCell.h
//  HarkPad
//
//  Created by Willem Bison on 20-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WorkInProgressTableCell : UITableViewCell {
    UILabel *labelTable;
    UILabel *labelTimer;
    UILabel *labelCourse;
}

@property (retain) IBOutlet UILabel *labelTable;
@property (retain) IBOutlet UILabel *labelCourse;
@property (retain) IBOutlet UILabel *labelTimer;

@end
