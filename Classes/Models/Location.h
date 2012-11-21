//
// Created by wbison on 28-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "DTO.h"

@class Address;

@interface Location : DTO

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) UIImage *logo;
@property(nonatomic, strong) id phone;
@property(nonatomic, strong) Address *address;

@end