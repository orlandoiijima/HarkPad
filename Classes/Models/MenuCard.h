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
}

+ (MenuCard *) menuFromJson: (NSMutableDictionary *) jsonData;
- (Product *) getProduct: (NSString *) productId;
- (Menu *) getMenu: (NSString *) menuId;
- (OrderLineProperty *) getProductProperty: (int)propertyId;


@property(nonatomic, strong) NSMutableArray *favorites;
@property(nonatomic, strong) NSMutableArray *menus;
@property(nonatomic, strong) NSMutableArray *categories;
@property(nonatomic, strong) NSDate *validFrom;
@end
