//
//  KitchenStatistics.h
//  HarkPad
//
//  Created by Willem Bison on 26-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KitchenStatistics : NSObject {
    int done;
    int inProgress;
    int inSlot;
    int notYetRequested;
}

@property int done;
@property int inProgress;
@property int inSlot;
@property int notYetRequested;

+ (KitchenStatistics *) statsFromJsonDictionary: (NSDictionary *)jsonDictionary;

@end
