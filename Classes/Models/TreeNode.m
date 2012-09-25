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

@synthesize name, color, nodes, parent, product, menu;

+ (TreeNode *) nodeFromJsonDictionary: (NSDictionary *)jsonDictionary parent: (TreeNode *) parent
{
    TreeNode *node = [[TreeNode alloc] initWithJson:jsonDictionary];
    node.name = [jsonDictionary objectForKey:@"name"];
    node.parent = parent;
    NSString *color = [jsonDictionary objectForKey:@"color"];
    if(color != nil)
        node.color = [node getColor:color];
    NSString *productId = [jsonDictionary objectForKey:@"productId"];
    if(productId != nil && (NSNull *)productId != [NSNull null])
        node.product = [[[Cache getInstance] menuCard] getProduct: productId];
    NSString *menuId = [jsonDictionary objectForKey:@"productCombinationId"];
    if(menuId != nil)
        node.menu = [[[Cache getInstance] menuCard] getMenu:menuId];
    [parent.nodes addObject: node];
    id nodes = [jsonDictionary objectForKey:@"nodes"];
    for(NSDictionary *childDic in nodes)
    {
        [TreeNode nodeFromJsonDictionary: childDic parent: node]; 
    }
    return node;
}

- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.nodes = [[NSMutableArray alloc] init];
        self.name = @"";
	}
    return(self);
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];

    if (self.parent != nil) {
        [dic setObject: [NSNumber numberWithInt:self.parent.id] forKey:@"parentId"];
        [dic setObject: [NSNumber numberWithInt:[self.parent.nodes indexOfObject:self]] forKey:@"sortOrder"];
    }
    if ([self.name length] > 0)
        [dic setObject: self.name forKey:@"name"];
    if (self.product != nil)
        [dic setObject: [NSNumber numberWithInt: self.product.id] forKey:@"productId"];
    return dic;
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
