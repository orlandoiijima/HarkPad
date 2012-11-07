//
// Created by wbison on 13-09-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PrinterInfo.h"


@implementation PrinterInfo {

}
@synthesize name = _name;
@synthesize address = _address;
@synthesize type = _type;


+ (PrinterInfo *)printerFromJson:(NSDictionary *)dictionary {
    PrinterInfo *printer = [[PrinterInfo alloc] init];
    printer.name = [dictionary objectForKey:@"name"];
    printer.address = [dictionary objectForKey:@"address"];
    printer.type = (PrinterType) [[dictionary objectForKey:@"printerType"] intValue];
    return printer;
}
@end