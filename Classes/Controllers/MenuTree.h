//
//  MenuTree.h
//  HarkPad
//
//  Created by Willem Bison on 12-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"

@interface MenuTree : UITableViewController {
    TreeNode *parentNode;
}

@property (retain) TreeNode *parentNode;

- (id)initWithStyle:(UITableViewStyle)style treeNode: (TreeNode *)node;
- (id)itemAtIndexPath: (NSIndexPath *)indexPath;
- (void) addNew;
- (void) addExisting;

@end
