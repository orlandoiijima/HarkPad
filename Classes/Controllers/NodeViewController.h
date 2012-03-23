//
//  NodeViewController.h
//  HarkPad
//
//  Created by Willem Bison on 01/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "ItemPropertiesDelegate.h"
#import "TreeNode.h"

@interface NodeViewController : UIViewController

@property (retain) IBOutlet UITextField *uiName;
@property (nonatomic, retain) id<ItemPropertiesDelegate> delegate;
@property (retain) TreeNode *node;
\
- (id)initWithNode:(TreeNode *)node delegate: (id<ItemPropertiesDelegate>) newDelegate;

- (IBAction) saveAction;
- (IBAction) cancelAction;
- (bool) validate;

@end
