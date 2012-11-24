//
// Created by wbison on 21-07-12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "StarPrintJob.h"
#import "Cache.h"
#import "PrintInfo.h"
#import "PrintColumn.h"
#import "RasterDocument.h"
#import "StarBitmap.h"
#import "Logger.h"
#import "ModalAlert.h"
#import "Session.h"
#import "Location.h"
#import "StarPrintOutputViewController.h"
#import "UIImage+Tint.h"
#import "MainTabBarController.h"
#import <StarIO/SMPort.h>
#import <sys/time.h>

@implementation StarPrintJob {

@private
    PrintTemplate *_template;
    id _dataSource;
    __unsafe_unretained NSString *_ip;
    float _y;
    float _x;
    float _tableOffset;
}
@synthesize template = _template;
@synthesize port = _port;
@synthesize dataSource = _dataSource;
@synthesize ip = _ip;
@synthesize y = _y;
@synthesize tableOffset = _tableOffset;


#define PAPERWIDTH 576

+ (StarPrintJob *)jobWithTemplate:(PrintTemplate *)template dataSource: (id) dataSource ip:(NSString *)ip {
    StarPrintJob *job = [[StarPrintJob alloc] init];
    job.dataSource = dataSource;
    job.ip = ip;
    job.template = template;
    return job;
}

-(void) print {
    UIImage *imageToPrint = [self createImage];
    StarPrintOutputViewController *controller = [StarPrintOutputViewController controllerWithImage:imageToPrint layoutTemplate:_template.name];
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    MainTabBarController *mainTabBarController = (MainTabBarController *)rootViewController.presentedViewController;
    if ([mainTabBarController isKindOfClass:[MainTabBarController class]]) {
        mainTabBarController.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        [mainTabBarController.popover presentPopoverFromRect:CGRectMake(0, 0, mainTabBarController.view.frame.size.width, 70) inView:mainTabBarController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
//    [self printImage:imageToPrint];
}

- (UIImage *)createImage {
    CGSize size = CGSizeMake(PAPERWIDTH, 5000);
    UIGraphicsBeginImageContext(size);

    CGContextRef ctr = UIGraphicsGetCurrentContext();

    [[UIColor whiteColor] set];
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(ctr, rect);

    [[UIColor blackColor] set];

    float defaultPointSize = _template.pointSize == 0 ? 20 : _template.pointSize;
    _y = _template.margin.top;

    for(Run *run in _template.preRuns) {
        [self print:run row:-1 section:-1 pointSize: defaultPointSize];
    }

    UIFont *font = [UIFont systemFontOfSize: _template.table.pointSize == 0 ? defaultPointSize : _template.table.pointSize];
    _tableOffset = [self updateY:_template.table.ySpec font:font];
    _y = 0;
    float rowHeight;
    int countSections = [_dataSource numberOfSections];
    for (NSUInteger section=0; section < countSections; section++) {
        int countRows = [_dataSource numberOfRowsInSection:section];
        if (countRows == 0)
            continue;

        [self print: _template.table.section row:-1 section: section pointSize: defaultPointSize];
        defaultPointSize = _template.table.pointSize == 0 ? defaultPointSize : _template.table.pointSize;
        for(NSUInteger row = 0; row < countRows; row++) {
            rowHeight = 0;
            float topOfRow = _y;
            for(PrintColumn *column in _template.table.columns) {
                _lineHeight = 0;
                float cellHeight = 0;
                for (Run *run in column.cellRuns) {
                    cellHeight += [self print:run row:row section:section pointSize:defaultPointSize];
                }
                if (cellHeight > rowHeight)
                    rowHeight = cellHeight;
                _y = topOfRow;
            }
            _tableOffset += rowHeight + _template.table.lineSpace;
            _y = topOfRow;
        }
    }

    _lineHeight = 0;
    for(PrintColumn *column in _template.table.columns) {
        for (Run *run in column.cellRuns) {
            Run *run = [run copy];
            run.text = column.footer;
            float height = [self print:run row:-1 section:-1 pointSize: defaultPointSize];
            if (height > _lineHeight)
                _lineHeight = height;
        }
    }
    _tableOffset += _lineHeight;

    defaultPointSize = _template.pointSize == 0 ? 20 : _template.pointSize;
    for(Run *run in _template.postRuns) {
        [self print:run row:-1 section:-1 pointSize: defaultPointSize];
    }

    _imageHeight += _template.margin.bottom;

    UIImage *image =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return [image imageByCroppingToRect:CGRectMake(0, 0, PAPERWIDTH, _imageHeight)];
}

-(float) print:(Run *)run row:(int)row section:(int)section pointSize:(float)pointSize {
    CGRect rect = CGRectZero;
    UIFont *font = [UIFont systemFontOfSize: run.pointSize == 0 ? pointSize : run.pointSize];
    if ([run.text isEqualToString:@"{logo}"]) {
        UIImage *logo = [UIImage imageNamed:@"anna-a-114x114.png"]; // [[[Cache getInstance] currentCompany] logo];
        if (logo != nil) {
            float height = ( run.width / logo.size.width) * logo.size.height;
            if (run.alignment == NSTextAlignmentCenter)
                rect = CGRectMake((PAPERWIDTH - run.width)/2, [self updateY:run.ySpec font:font], run.width, height);
            else
                rect = CGRectMake([run.xSpec intValue], [self updateY:run.ySpec font:font], run.width, height);
            [logo drawInRect: rect];
        }
    }
    else {
        NSString *textToDraw = [run evaluateWithProvider:_dataSource row:row section:section];
        if ([textToDraw length] > 0) {
            NSString *ySpec = run.ySpec;
            if (run.alignment == NSTextAlignmentCenter) {
                CGSize measuredSize = [textToDraw sizeWithFont:font constrainedToSize:CGSizeMake(PAPERWIDTH, 200) lineBreakMode:NSLineBreakByWordWrapping];
                rect = CGRectMake(0, [self updateY:ySpec font:font], PAPERWIDTH, measuredSize.height);
            }
            else {
                [self updateX:run.xSpec font:font];
                int width = run.width == 0 ? PAPERWIDTH - _x : run.width;
                CGSize measuredSize = [textToDraw sizeWithFont:font constrainedToSize:CGSizeMake(width, 200) lineBreakMode:NSLineBreakByWordWrapping];
                rect = CGRectMake(_x, [self updateY:ySpec font:font], width, measuredSize.height);
            }
            [textToDraw drawInRect:rect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment: run.alignment];
        }
    }

    if (rect.size.height > 0)
        _lineHeight = rect.size.height;

    if (CGRectGetMaxY(rect) > _imageHeight)
        _imageHeight = CGRectGetMaxY(rect);
    
    return rect.size.height;
}

- (float) updateY: (NSString *)ySpec font: (UIFont *)font {
    if ([ySpec length] == 0) {
        _y +=_lineHeight;
    }
    else
    if ([ySpec characterAtIndex:0] == '+') {
        int delta = MAX(0, [ySpec characterAtIndex:1] - '0');
        if (delta == 0) {

        }
        else {
            _y +=_lineHeight;
            CGSize measuredSize = [@"x" sizeWithFont:font constrainedToSize:CGSizeMake(1000, 200) lineBreakMode:NSLineBreakByWordWrapping];
            _y += (delta - 1) * measuredSize.height;
        }
    }
    else {
        _y = [ySpec floatValue];
    }
    return _y + _tableOffset;
}

- (float) updateX: (NSString *)xSpec font: (UIFont *)font {
    if ([xSpec length] == 0) {
        _x = _template.margin.left;
    }
    else
    if ([xSpec characterAtIndex:0] == '+') {
        int delta = MAX(0, [xSpec characterAtIndex:1] - '0');
        CGSize measuredSize = [@"x" sizeWithFont:font constrainedToSize:CGSizeMake(1000, 200) lineBreakMode:NSLineBreakByWordWrapping];
        _x = _x + delta * measuredSize.width;
    }
    else {
        _x = [xSpec floatValue];
    }
    return _x;
}

- (void)printImage: (UIImage*)imageToPrint
{
    NSString *portName = [@"TCP:" stringByAppendingString:_ip];
    NSString *portSettings = @"";
    int maxWidth = PAPERWIDTH;

    RasterDocument *rasterDoc = [[RasterDocument alloc] initWithDefaults:RasSpeed_Medium endOfPageBehaviour:RasPageEndMode_FeedAndFullCut endOfDocumentBahaviour:RasPageEndMode_FeedAndFullCut topMargin:RasTopMargin_Standard pageLength:0 leftMargin:0 rightMargin:0];
    StarBitmap *starBitmap = [[StarBitmap alloc] initWithUIImage:imageToPrint :maxWidth :false];

    NSMutableData *commandsToPrint = [[NSMutableData alloc]init];
    NSData *shortCommand = [rasterDoc BeginDocumentCommandData];
    [commandsToPrint appendData:shortCommand];

    shortCommand = [starBitmap getImageDataForPrinting];
    [commandsToPrint appendData:shortCommand];

    shortCommand = [rasterDoc EndDocumentCommandData];
    [commandsToPrint appendData:shortCommand];

    int commandSize = [commandsToPrint length];
    unsigned char *dataToSentToPrinter = (unsigned char*)malloc(commandSize);
    [commandsToPrint getBytes:dataToSentToPrinter];

    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :5000];

        if(starPort == nil)
        {
            NSString *msg = [NSString stringWithFormat: NSLocalizedString(@"Failed to start printjob. Check if the printer is turned on and connected to the network (ip %@)", nil), _ip];
            [ModalAlert error:msg];
            return;
        }

        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;

        int totalAmountWritten = 0;
        while(totalAmountWritten < commandSize)
        {
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :commandSize];
            totalAmountWritten += amountWritten;

            struct timeval now;
            gettimeofday(&now, NULL);
            if(now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        if(totalAmountWritten < commandSize)
        {
            [ModalAlert error:NSLocalizedString(@"Printer timeout", nil)];
        }

    }
    @catch (PortException *exception)
    {
        [ModalAlert error:NSLocalizedString(@"Printer timeout", nil)];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }

    free(dataToSentToPrinter);
}

@end