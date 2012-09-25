//
//  ProductFolder.h
//  HarkPad2
//
//  Created by Willem Bison on 03-11-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"
#import "Menu.h"

@interface TreeNode : DTO {
    NSString *name;
    NSMutableArray *nodes;
    TreeNode *parent;
    UIColor *color;
    Product *product;
    Menu *menu;
}

@property (retain) NSString *name;
@property (retain) NSMutableArray *nodes;
@property (retain) TreeNode *parent;
@property (retain) UIColor *color;
@property (retain) Product *product;
@property (retain) Menu *menu;

+ (TreeNode *) nodeFromJsonDictionary: (NSDictionary *)jsonDictionary parent: (TreeNode *)parent;
- (UIColor *) getColor: (NSString *)color;
- (TreeNode *) getNode: (int)nodeId;
- (NSMutableDictionary *)toDictionary;

@end
