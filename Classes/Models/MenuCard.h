//
//  Menu.h
//  HarkPad
//
//  Created by Willem Bison on 02-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "ProductCategory.h"
#import "Product.h"
#import "Menu.h"
#import "OrderLineProperty.h"

@interface MenuCard : NSObject {
    NSMutableArray *categories;
    NSMutableArray *menus;
}

+ (MenuCard *) menuFromJson: (NSMutableArray *) jsonData;
- (Product *) getProduct: (int) productId;
- (Menu *) getMenu: (int) menuId;
- (OrderLineProperty *) getProductProperty: (int)propertyId;

@property (retain) NSMutableArray *categories;
@property (retain) NSMutableArray *menus;

@end
