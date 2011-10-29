//
//  MenuTreeViewController.h
//  HarkPad
//
//  Created by Willem Bison on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GridViewController.h"
#import "TreeNode.h"

@interface MenuTreeViewController : GridViewController {
    TreeNode *parentNode;
    TreeNode *rootNode;
}

@property (retain) TreeNode *parentNode;
@property (retain) TreeNode *rootNode;

@end
