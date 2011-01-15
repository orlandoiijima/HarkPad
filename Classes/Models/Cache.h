//
//  Cache.h
//  HarkPad
//
//  Created by Willem Bison on 25-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuCard.h"
#import "Menu.h"
#import "Map.h"
#import "TreeNode.h"

@interface Cache : NSObject {
}

+ (Cache *) getInstance;

@property (retain) MenuCard *menuCard;
@property (retain) Map *map;
@property (retain) TreeNode *tree;
@end
