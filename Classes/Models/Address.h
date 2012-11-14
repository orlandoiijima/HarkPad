//
// Created by wbison on 08-11-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "DTO.h"

@interface Address : DTO
@property(nonatomic, strong) NSString * street;
@property(nonatomic, strong) NSString * number;
@property(nonatomic, strong) NSString * zipCode;
@property(nonatomic, strong) NSString * city;


- (id)initWithDictionary:(NSMutableDictionary *)o;
@end