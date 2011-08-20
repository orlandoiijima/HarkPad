//
//  Splitter.h
//  HarkPad2
//
//  Created by Willem Bison on 11-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Splitter : UIView {
}

@property int position;
@property int width;
@property (retain) UIView *firstView;
@property (retain) UIView *secondView;
@property CGPoint startDrag;
@property BOOL isDrag;
@property (retain) UIViewController *controller;

- (void)setupWithView: (UIView *) first secondView : (UIView *)second controller: (UIViewController*)controller position: (int) pos width: (int) width;

- (void) collapseFirst;
- (void) expandFirst;
@end
