	//
//  Utils.m
//  HarkPad2
//
//  Created by Willem Bison on 29-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Utils.h"


@implementation Utils


+ (NSString *) getSeatString: (int) seat
{
    return [NSString stringWithFormat:@"Stoel %d", seat+1]; 
}

+ (NSString *) getSeatChar: (int) seat
{
    return [NSString stringWithFormat:@"%d", seat+1]; 
}

+ (NSString *) getCourseString: (int) course
{
    return [NSString stringWithFormat:@"Gang %@", [self getCourseChar: course]]; 
}

+ (NSString *) getCourseChar: (int) course
{
    NSArray *chars = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",nil];
    if(course < 0 || course >= [chars count])
    {
        return @"";
    }
    return [NSString stringWithFormat:@"%@", [chars objectAtIndex: course]]; 
}

+ (NSString *) getElapsedMinutesString: (NSDate *) date
{
    int elapsed = -1 * [date timeIntervalSinceNow];
    NSString *hour = elapsed > 3600 ? [NSString stringWithFormat:@"%d ", elapsed / 3600] : @"";  
    return [NSString stringWithFormat:@"%@%d'", hour, (elapsed / 60) % 60];
}


+ (NSString *) getAmountString: (NSDecimalNumber *)amount withCurrency: (bool) withCurrency
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    if(withCurrency == false)
        [formatter setCurrencySymbol:@""];	
    return [formatter stringFromNumber:amount];
}

+ (NSDecimalNumber *) getAmountFromString: (NSString *)amount
{
    return [NSDecimalNumber decimalNumberWithString:amount locale: [NSLocale currentLocale]];
}

+ (NSString *) trim: (NSString *) text
{
    return [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];    
}

@end
