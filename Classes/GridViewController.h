//
//  GridViewController.h
//  HarkPad
//
//  Created by Willem Bison on 15-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridView.h"
#import "GridViewCellLine.h"

@interface GridViewController : UIViewController <GridViewDataSource, UIScrollViewDelegate, GridViewDelegate> {
    GridView *gridView;
}

@property (retain) GridView *gridView;

@end
