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
    printer.name = [dictionary objectForKey:@"Name"];
    printer.address = [dictionary objectForKey:@"Address"];
    printer.type = (PrinterType) [[dictionary objectForKey:@"PrinterType"] intValue];
    return printer;
}
@end