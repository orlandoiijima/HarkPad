//
//  ProductFolder.m
//  HarkPad2
//
//  Created by Willem Bison on 03-11-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Treenode.h"
#import "Cache.h"

@implementation TreeNode

@synthesize name, sortOrder, id, color, nodes, parent, product, menu;

+ (TreeNode *) nodeFromJsonDictionary: (NSDictionary *)jsonDictionary parent: (TreeNode *) parent
{
    TreeNode *node = [[TreeNode alloc] init];
    node.id = [[jsonDictionary objectForKey:@"id"] intValue];
    node.name = [jsonDictionary objectForKey:@"name"];
    node.nodes = [[NSMutableArray alloc] init];
    node.parent = parent;
    NSString *color = [jsonDictionary objectForKey:@"color"];
    if((NSNull *)color != [NSNull null])
        node.color = [node getColor:color];
    NSNumber *productId = [jsonDictionary objectForKey:@"productId"];
    if((NSNull *)productId != [NSNull null])
        node.product = [[[Cache getInstance] menuCard] getProduct:[productId intValue]];
    NSNumber *menuId = [jsonDictionary objectForKey:@"menuId"];
    if((NSNull *)menuId != [NSNull null])
        node.menu = [[[Cache getInstance] menuCard] getMenu:[menuId intValue]];
    [parent.nodes addObject: node];
    id nodes = [jsonDictionary objectForKey:@"nodes"];
    for(NSDictionary *childDic in nodes)
    {
        [TreeNode nodeFromJsonDictionary: childDic parent: node]; 
    }
    return node;
}

- (UIColor *) getColor: (NSString *)colorString
{
    if(colorString == nil)
//	        return
//    if((NSNull *)colorString == [NSNull null])
        return [UIColor blackColor];
    char *c = (char*)[colorString UTF8String];
    unsigned long lcolor = strtoul(c, nil, strlen(c));
    float red = ((lcolor >> 24) & 0xFF) / 255.0;
    float green = ((lcolor >> 16) & 0xFF) / 255.0;
    float blue = ((lcolor >> 8) & 0xFF) / 255.0;
    float alpha = (lcolor & 0xFF) / 255.0; 
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


- (TreeNode *) getNode: (int)nodeId
{
    if(self.id == nodeId)
        return self;
    
    for(TreeNode *node in nodes)
    {
        id found = [node getNode:nodeId];
        if(found != nil) return found;
    }
    return nil;
}

@end
