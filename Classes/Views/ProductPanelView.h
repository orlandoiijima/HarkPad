//
//  ProductPanelView.h
//  HarkPad2
//
//  Created by Willem Bison on 24-11-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"

@interface ProductPanelView : UIView {
    TreeNode *rootNode;
    TreeNode *parentNode;
}

- (void) drawProductButton: (int)column row: (int)row productNode: (TreeNode *)node;
- (void) drawMenuButton: (int)column row: (int)row menuNode: (TreeNode *)node;
- (void) drawNavigateButton: (int)column row: (int)row label:(NSString*) label targetNode: (TreeNode *)node;
- (void) drawPanelButton: (int)column row: (int)row label: (NSString *) label font: (UIFont *) font textColor:(UIColor*)textColor backgroundColor:(UIColor*)bgColor targetNode: (TreeNode *)node;
- (TreeNode *) treeNodeByPoint: (CGPoint) point frame: (CGRect *)rect;
- (CGRect) getButtonRect : (int) column row : (int) row;
- (void) setupMenuCard: (CGRect) containerFrame;

@property (retain) TreeNode *parentNode, *rootNode;
@property (retain) UISegmentedControl *menuCardSegment;
@end
