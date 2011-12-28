//
//  Menu.m
//  HarkPad
//
//  Created by Willem Bison on 02-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "MenuCard.h"

@implementation MenuCard

@synthesize categories, menus;

- (id)init {
    if ((self = [super init])) {
        {
            categories = [[NSMutableArray alloc] init];          
        }
    }
    return self;
}

+ (MenuCard *) menuFromJson:(NSMutableArray *)jsonCategories
{
    MenuCard *menu = [[MenuCard alloc] init];
    for(NSDictionary *categoryDic in jsonCategories)
    {
        ProductCategory *category = [ProductCategory categoryFromJsonDictionary: categoryDic]; 
        [menu.categories addObject:category];
    }
    return menu;
}

- (Product *) getProduct: (int) productId
{
    for(ProductCategory *category in categories)
    {
        for(Product *product in category.products)
        {
            if(product.id == productId)
                return product;
        }    
    }
    NSLog([NSString stringWithFormat:@"product %d not found", productId]);
    return nil;
}

- (Menu *) getMenu: (int) menuId
{
    for(Menu *menu in menus)
    {
        if(menu.id == menuId)
            return menu;
    }   
    NSLog([NSString stringWithFormat:@"menu %d not found", menuId]);
    return nil;
}

- (OrderLineProperty *) getProductProperty: (int)propertyId
{
    for(ProductCategory *category in categories)
    {
        for(Product *product in category.products)
        {
            for(OrderLineProperty * prop in [product properties])
            {
                if(prop.id == propertyId)
                    return prop;
            }
        }    
    }      
    return nil;
}
@end
