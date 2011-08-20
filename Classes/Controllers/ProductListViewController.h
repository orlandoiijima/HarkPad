//
//  ProductListViewController.h
//  HarkPad
//
//  Created by Willem Bison on 13-06-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface ProductListViewController : UITableViewController {
    
}

- (Product *) productForIndexPath: (NSIndexPath *) indexPath;

@end
