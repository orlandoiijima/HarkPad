//
// Created by wbison on 10-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "DTO.h"

@class Address;


@interface Company : DTO
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) Address *address;
@property(nonatomic, strong) UIImage *logo;
@end