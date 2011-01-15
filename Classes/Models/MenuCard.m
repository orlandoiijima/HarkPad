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

+ (MenuCard *) menuFromJson:(NSData *)jsonData
{
    MenuCard *menu = [[MenuCard alloc] init];
    NSError *error = nil;
	NSMutableArray *categories = [[CJSONDeserializer deserializer] deserializeAsArray:jsonData error:&error ];
    for(NSDictionary *categoryDic in categories)
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
    return nil;
}

- (Menu *) getMenu: (int) menuId
{
    for(Menu *menu in menus)
    {
        if(menu.id == menuId)
            return menu;
    }   
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
