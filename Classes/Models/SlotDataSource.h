//
//  SlotDataSource.h
//  HarkPad
//
//  Created by Willem Bison on 21-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Slot.h"

@interface SlotDataSource : NSObject <UITableViewDataSource, UITableViewDelegate> {
    Slot *slot;
}

@property (retain) Slot *slot;

+ (SlotDataSource *) dataSourceForSlot: (Slot *)slot;

@end
