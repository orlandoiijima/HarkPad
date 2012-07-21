//
//  Created by wbison on 26-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BillPdf.h"
#import "PdfCreator.h"
#import "Utils.h"


@implementation BillPdf {
}

@synthesize order = _order, orderDataSource = _orderDataSource;

+ (BillPdf *)billByOrder: (Order *)order {
    BillPdf *pdf = [[BillPdf alloc] init];
    pdf.order = order;
    return pdf;
}

- (NSString *)create
{
    _orderDataSource = [OrderDataSource dataSourceForOrder:self.order grouping: noGrouping totalizeProducts:YES showFreeProducts:NO showProductProperties:NO isEditable:NO showPrice:NO showEmptySections:NO fontSize:12];

    PdfCreator *creator = [PdfCreator pdfCreatorWithTemplateNamed: @"invoice"];

    NSString *fileName = [NSString stringWithFormat:@"Invoice%d.pdf", _order.id];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfFileName = [documentsDirectory stringByAppendingPathComponent:fileName];
    [creator createFileAtPath: pdfFileName delegate:self];

    return pdfFileName;
}

- (NSUInteger)numberOfRowsInSection:(NSInteger)section {
    return (NSUInteger) [_orderDataSource tableView:nil numberOfRowsInSection:0];
}

- (NSUInteger)numberOfSections {
    return 1;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSString *)stringForVariable:(NSString *)variable {
    if ([variable compare: @"{nowDate}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];

    if ([variable compare: @"{nowTime}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];

    if ([variable compare: @"{id}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return [NSString stringWithFormat:@"%d", self.order.id];

    if ([variable compare: @"{table}" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
        if (self.order.table == nil) return @"";
        return [NSString stringWithFormat:@"%@",  self.order.table.name];
    }
    return variable;
}

- (NSString *)stringForVariable:(NSString *)variable row:(NSUInteger)row section:(NSUInteger)section {
    if (row < [_orderDataSource tableView:nil numberOfRowsInSection:0]) {
        OrderLine *line = [_orderDataSource orderLineAtIndexPath: [NSIndexPath indexPathForRow:row inSection:0]];
        if (line == nil) return @"";
        if ([variable compare: @"{productName}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
            return line.product.name;
        if ([variable compare: @"{productKey}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
            return line.product.key;
        if ([variable compare: @"{quantity}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
            return [NSString stringWithFormat:@"%d", line.quantity];
        if ([variable compare: @"{amount}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
            return [NSString stringWithFormat:@"%@", [Utils getAmountString:line.getAmount withCurrency:YES]];
    }
    if ([variable compare: @"{amountTotal}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return [NSString stringWithFormat:@"%@", [Utils getAmountString: self.order.totalAmount withCurrency:YES]];
    return @"";
}

@end