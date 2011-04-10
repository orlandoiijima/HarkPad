//
//  KitchenStatisticsDataSource.h
//  HarkPad
//
//  Created by Willem Bison on 10-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Backlog.h"

@interface KitchenStatisticsDataSource : NSObject <UITableViewDataSource, UITableViewDelegate> {
    NSMutableDictionary *groupedTotals;    
}

@property (retain) NSMutableDictionary *groupedTotals;

- (NSString *) keyForSection: (int) section;
+ (KitchenStatisticsDataSource *) dataSource;
- (UILabel *) addCountLabelWithFrame: (CGRect) frame backgroundColor: (UIColor *) color cell: (UITableViewCell *)cell;

@end
