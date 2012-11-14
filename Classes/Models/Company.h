//
// Created by wbison on 10-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "DTO.h"

@class Address;


@interface Company : DTO
@property (nonatomic) NSString *name;
@property (retain) Address *address;
@property (nonatomic, strong) UIImage *logo;
@property(nonatomic, strong) NSString * locationId;
@property(nonatomic, strong) NSString * accountId;
@property(nonatomic) NSString *phone;
@end