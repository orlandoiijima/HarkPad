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

@interface MenuCard : DTO {
}

+ (MenuCard *) menuFromJson: (NSMutableDictionary *) jsonData;
- (Product *) getProduct: (NSString *) productId;

- (NSString *)vatNameByPercentage:(NSDecimalNumber *)vat;
- (int)vatIndexByPercentage:(NSDecimalNumber *)vat;


- (Menu *) getMenu: (NSString *) menuId;
- (OrderLineProperty *) getProductProperty: (int)propertyId;


@property(nonatomic, strong) NSMutableArray *favorites;
@property(nonatomic, strong) NSMutableArray *menus;
@property(nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *vatPercentages;
@property(nonatomic, strong) NSDate *validFrom;
@end
