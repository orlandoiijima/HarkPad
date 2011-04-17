//
//  DragNode.h
//  HarkPad2
//
//  Created by Willem Bison on 25-11-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreeNode.h" 
#import "OrderLine.h"

@interface DragNode : UIView {
    OrderLine *orderLine;
    NSString *label;
    TreeNode *treeNode;
}

+ (DragNode *) nodeWithNode : (TreeNode *) product frame: (CGRect) frame;
+ (DragNode *) nodeWithOrderLine : (OrderLine *) orderLine frame: (CGRect) frame;

@property (retain) TreeNode *treeNode;
@property (retain) NSString *label;
@property (retain) OrderLine *orderLine;
@end
