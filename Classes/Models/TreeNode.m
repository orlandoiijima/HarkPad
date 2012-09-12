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

@synthesize name, id, color, nodes, parent, product, menu;

+ (TreeNode *) nodeFromJsonDictionary: (NSDictionary *)jsonDictionary parent: (TreeNode *) parent
{
    TreeNode *node = [[TreeNode alloc] init];
    node.id = [[jsonDictionary objectForKey:@"Id"] intValue];
    node.name = [jsonDictionary objectForKey:@"Name"];
    node.parent = parent;
    NSString *color = [jsonDictionary objectForKey:@"Color"];
    if(color != nil)
        node.color = [node getColor:color];
    NSString *productId = [jsonDictionary objectForKey:@"ProductId"];
    if(productId != nil && (NSNull *)productId != [NSNull null])
        node.product = [[[Cache getInstance] menuCard] getProduct: productId];
    NSString *menuId = [jsonDictionary objectForKey:@"ProductCombinationId"];
    if(menuId != nil)
        node.menu = [[[Cache getInstance] menuCard] getMenu:menuId];
    [parent.nodes addObject: node];
    id nodes = [jsonDictionary objectForKey:@"Nodes"];
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
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (self.parent != nil) {
        [dic setObject: [NSNumber numberWithInt:self.parent.id] forKey:@"ParentId"];
        [dic setObject: [NSNumber numberWithInt:[self.parent.nodes indexOfObject:self]] forKey:@"SortOrder"];
    }
    if ([self.name length] > 0)
        [dic setObject: self.name forKey:@"Name"];
    if (self.product != nil)
        [dic setObject: [NSNumber numberWithInt: self.product.id] forKey:@"ProductId"];
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
