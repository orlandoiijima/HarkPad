//
//  WorkInProgressDataSource.h
//  HarkPad
//
//  Created by Willem Bison on 20-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Service.h"
#import "WorkInProgressTableCell.h"

@interface WorkInProgressDataSource : NSObject <UITableViewDataSource> {
    NSMutableArray *workInProgress;
}


@property (retain) NSMutableArray *workInProgress;

//+ (WorkInProgressDataSource *) dataSource;

@end
