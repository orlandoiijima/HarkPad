//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BillPdf.h"
#import "Order.h"
#import "PdfCreator.h"
#import "Utils.h"


@implementation BillPdf {
}

@synthesize order = _order;

+ (BillPdf *)billByOrder: (Order *)order {
    BillPdf *pdf = [[BillPdf alloc] init];
    pdf.order = order;
    return pdf;
}

- (NSString *)create
{
    NSMutableDictionary *template = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *text = [[NSMutableDictionary alloc] init];
    [text setObject:[NSNumber numberWithInt:10] forKey:@"x"];
    [text setObject:[NSNumber numberWithInt:10] forKey:@"y"];
    [text setObject:[NSNumber numberWithInt:200] forKey:@"width"];
    [text setObject:@"Datum: {nowDate} {nowTime}" forKey:@"text"];

    NSMutableDictionary *text2 = [[NSMutableDictionary alloc] init];
    [text2 setObject:[NSNumber numberWithInt:10] forKey:@"x"];
    [text2 setObject:[NSNumber numberWithInt:200] forKey:@"width"];
    [text2 setObject:@"Rekening: {id}" forKey:@"text"];

    [template setObject: [NSArray arrayWithObjects:text, text2, nil] forKey:@"texts"];

    NSMutableDictionary *table = [[NSMutableDictionary alloc] init];
    [template setObject:table forKey:@"table"];
    [table setObject:[NSNumber numberWithInt:100] forKey:@"x"];
    [table setObject:[NSNumber numberWithInt:100] forKey:@"y"];
    [table setObject:[NSNumber numberWithFloat: 8.2] forKey:@"fontSize"];

    NSMutableDictionary *column1 = [[NSMutableDictionary alloc] init];
    [column1 setObject:@"{quantity}" forKey:@"text"];
    [column1 setObject:[NSNumber numberWithInt:50] forKey:@"width"];
    [column1 setObject:[NSNumber numberWithInt:2] forKey:@"alignment"];

    NSMutableDictionary *column2 = [[NSMutableDictionary alloc] init];
    [column2 setObject:@"{productName}" forKey:@"text"];
    [column2 setObject:[NSNumber numberWithInt:150] forKey:@"width"];

    NSMutableDictionary *column3 = [[NSMutableDictionary alloc] init];
    [column3 setObject:@"{amount}" forKey:@"text"];
    [column3 setObject:[NSNumber numberWithInt:150] forKey:@"width"];
    [column3 setObject:[NSNumber numberWithInt:2] forKey:@"alignment"];
    [table setObject: [NSArray arrayWithObjects: column1, column2, column3, nil] forKey:@"columns"];
    
    PdfCreator *creator = [PdfCreator pdfCreatorWithTemplate: template];

    NSString *fileName = [NSString stringWithFormat:@"Invoice%d.pdf", _order.id];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName = [documentsDirectory stringByAppendingPathComponent:fileName];
    [creator createFileAtPath: pdfFileName delegate:self];

    return pdfFileName;
}

- (NSUInteger)countOfRows {
    return [_order.lines count];
}

- (NSString *)stringForVariable:(NSString *)variable {
    if ([variable isEqualToString:@"{nowDate}"]) {
        return [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    }
    if ([variable isEqualToString:@"{nowTime}"]) {
        return [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    }
    if ([variable isEqualToString:@"{id}"]) {
        return [NSString stringWithFormat:@"%d", self.order.id];
    }
    return variable;
}

- (NSString *)stringForVariable:(NSString *)variable inRow:(NSUInteger)row {
    if (row >= [self.order.lines count])
        return @"";
    OrderLine *line = [self.order.lines objectAtIndex:row];
    if ([variable isEqualToString:@"{productName}"])
        return line.product.name;
    if ([variable isEqualToString:@"{productKey}"])
        return line.product.key;
    if ([variable isEqualToString:@"{quantity}"])
        return [NSString stringWithFormat:@"%d", line.quantity];
    if ([variable isEqualToString:@"{amount}"])
        return [NSString stringWithFormat:@"%@", [Utils getAmountString:line.getAmount withCurrency:YES]];
    return @"";
}

@end