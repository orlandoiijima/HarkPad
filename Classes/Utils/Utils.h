//
//  Utils.h
//  HarkPad2
//
//  Created by Willem Bison on 29-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject {
}

+ (NSString *) getSeatString: (int) seat;
+ (NSString *) getCourseString: (int) course;
+ (NSString *) getSeatChar: (int) seat;
+ (NSString *) getCourseChar: (int) course;
+ (NSString *) getElapsedMinutesString: (NSDate *) date;
+ (NSString *) getAmountString: (NSDecimalNumber *)amount withCurrency: (bool) withCurrency;
+ (NSDecimalNumber *) getAmountFromString: (NSString *)amount;
+ (NSString *) trim: (NSString *) text;

+ (void)setModifiedValue:(NSString *)val forKey:(NSString *)key ofObject:(id)o;


@end
