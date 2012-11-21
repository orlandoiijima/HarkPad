//
// Created by wbison on 14-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "OrderPrinter.h"
#import "Order.h"
#import "Print.h"
#import "OrderDataSource.h"
#import "OrderLineFilter.h"
#import "Utils.h"
#import "Logger.h"
#import "Location.h"
#import "Address.h"
#import "AppVault.h"
#import "Session.h"
#import "PrinterInfo.h"


@implementation OrderPrinter {
}
@synthesize order = _order;
@synthesize trigger = _trigger;
@synthesize orderDataSource = _orderDataSource;

+ (OrderPrinter *)printerAtTrigger: (OrderTrigger)trigger order: (Order *)order {
    OrderPrinter *printer = [[OrderPrinter alloc] init];
    printer.order = order;
    printer.trigger = trigger;

    return printer;
}

- (void) print {
    for (OrderDocumentDefinition *document in [[[Cache getInstance] printInfo] getDocumentDefinitionsForTrigger:_trigger]) {
        self.orderDataSource = [OrderDataSource
                dataSourceForOrder:_order
                          grouping: noGrouping
                  totalizeProducts:document.totalizeProducts
                  showFreeProducts:document.filter.zeroPrice
             showProductProperties:NO
                        isEditable:NO
                         showPrice:NO
                 showEmptySections:NO
                          fontSize:12];
        _orderDocument = document;
        [Print printWithDataSource:self withDocument:document toPrinter:document.printer];
    }
}

- (int)countAvailableDocumentDefinitions {
    NSMutableArray *documents = [[[Cache getInstance] printInfo] getDocumentDefinitionsForTrigger:_trigger];
    return [documents count];
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

- (NSString *)stringForVariable:(NSString *)variable row:(int)row section:(int)section {

    if ([variable compare: @"{documentName}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return _orderDocument.name;

    if ([variable compare: @"{printerName}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return _orderDocument.printer.name;

    if ([variable compare: @"{userName}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return [[Session authenticatedUser] firstName];

    Location *currentLocation = [[Cache getInstance] currentLocation];
    if ([variable compare: @"{companyName}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return currentLocation == nil ? @"" :  currentLocation.name;
    if ([variable compare: @"{locationAddressStreet}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return currentLocation == nil ? @"" :  currentLocation.address.street;
    if ([variable compare: @"{locationAddressZipCode}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return currentLocation == nil ? @"" :  currentLocation.address.zipCode;
    if ([variable compare: @"{locationAddressCity}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return currentLocation == nil ? @"" :  currentLocation.address.city;
    if ([variable compare: @"{locationPhone}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return currentLocation == nil ? @"" :  currentLocation.phone;

    if ([variable compare: @"{nowDate}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];

    if ([variable compare: @"{nowTime}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];

    if ([variable compare: @"{id}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return [NSString stringWithFormat:@"%d", _orderDataSource.order.id];

    if ([variable compare: @"{tableName}" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
        if (_orderDataSource.order.table == nil) return @"";
        return [NSString stringWithFormat:@"%@",  _orderDataSource.order.table.name];
    }

    if (row >= 0 && row < [_orderDataSource tableView:nil numberOfRowsInSection: section]) {
        OrderLine *line = [_orderDataSource orderLineAtIndexPath: [NSIndexPath indexPathForRow:row inSection: section]];
        if (line == nil) return @"";
        if ([variable compare: @"{productName}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
            return line.product.name;
        if ([variable compare: @"{productKey}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
            return line.product.key;
        if ([variable compare: @"{quantity}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
            return [NSString stringWithFormat:@"%d", line.quantity];
        if ([variable compare: @"{amount}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
            return [NSString stringWithFormat:@"%@", [Utils getAmountString:line.getAmount withCurrency:YES]];
        if ([variable compare: @"{amountVat}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
            return [NSString stringWithFormat:@"%@", [Utils getAmountString:line.getVatAmount withCurrency:YES]];
        if ([variable compare: @"{amountNett}" options: NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSDecimalNumber *nettAmount = [line.getAmount decimalNumberBySubtracting: line.getVatAmount];
            return [NSString stringWithFormat:@"%@", [Utils getAmountString: nettAmount withCurrency:YES]];
        }
    }

    if ([variable compare: @"{amountTotal}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return [NSString stringWithFormat:@"%@", [Utils getAmountString: _orderDataSource.order.totalAmount withCurrency:YES]];
    if ([variable compare: @"{amountVatTotal}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
        return [NSString stringWithFormat:@"%@", [Utils getAmountString: _orderDataSource.order.totalVatAmount withCurrency:YES]];
    if ([variable compare: @"{amountNettTotal}" options: NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        NSDecimalNumber *nettAmount = [_orderDataSource.order.totalAmount decimalNumberBySubtracting: _orderDataSource.order.totalVatAmount];
        return [NSString stringWithFormat:@"%@", [Utils getAmountString: nettAmount withCurrency:YES]];
    }

    [Logger error:[NSString stringWithFormat:@"Unknown variable '%@'", variable]];
    return @"";
}

@end