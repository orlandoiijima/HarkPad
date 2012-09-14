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
#import <StarIO/SMPort.h>
#import <sys/time.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation StarPrintJob {

@private
    PrintTemplate *_template;
    id _dataSource;
    __unsafe_unretained NSString *_ip;
    int _y;
    int _tableOffset;
}
@synthesize template = _template;
@synthesize port = _port;
@synthesize dataSource = _dataSource;
@synthesize ip = _ip;
@synthesize y = _y;
@synthesize tableOffset = _tableOffset;


+ (StarPrintJob *)jobWithTemplate:(PrintTemplate *)template dataSource: (id) dataSource ip:(NSString *)ip {
    StarPrintJob *job = [[StarPrintJob alloc] init];
    job.dataSource = dataSource;
    job.ip = ip;
    job.template = template;
    return job;
}

-(void) print {
    @try {
        NSString *ipParameter = [@"TCP:" stringByAppendingString:_ip];

        CGSize size = CGSizeMake(576, 1000);
		UIGraphicsBeginImageContext(size);

        CGContextRef ctr = UIGraphicsGetCurrentContext();
        UIColor *color = [UIColor whiteColor];
        [color set];

        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        CGContextFillRect(ctr, rect);

        color = [UIColor blackColor];
        [color set];

        float defaultPointSize = _template.pointSize == 0 ? 20 : _template.pointSize;
        _y = 0;

        for(Run *run in _template.preRuns) {
            [self print:run row:-1 section:-1 pointSize: defaultPointSize];
        }

        UIFont *font = [UIFont systemFontOfSize: _template.table.pointSize == 0 ? defaultPointSize : _template.table.pointSize];
        _tableOffset = [self updateY:_template.table.ySpec font:font];
        _y = 0;
        float lineHeight = 0;
        int countSections = [_dataSource numberOfSections];
        for (NSUInteger section=0; section < countSections; section++) {
            int countRows = [_dataSource numberOfRowsInSection:section];
            if (countRows == 0)
                continue;
    
            [self print: _template.table.section row:-1 section: section pointSize: defaultPointSize];
            defaultPointSize = _template.table.pointSize == 0 ? defaultPointSize : _template.table.pointSize;
            for(NSUInteger row = 0; row < countRows; row++) {
                for(PrintColumn *column in _template.table.columns) {
                    float height = [self print:column.cell row:row section:section pointSize: defaultPointSize];
                    if (height > lineHeight)
                        lineHeight = height;
                }
                _tableOffset += lineHeight;
            }
        }

        lineHeight = 0;
        for(PrintColumn *column in _template.table.columns) {
            Run *run = [column.cell copy];
            run.text = column.footer;
            float height = [self print:run row:-1 section:-1 pointSize: defaultPointSize];
            if (height > lineHeight)
                lineHeight = height;
        }
        _tableOffset += lineHeight;

        defaultPointSize = _template.pointSize == 0 ? 20 : _template.pointSize;
        for(Run *run in _template.postRuns) {
            [self print:run row:-1 section:-1 pointSize: defaultPointSize];
        }

        UIImage *imageToPrint = UIGraphicsGetImageFromCurrentImageContext();
        [self printImageWithPortname:ipParameter portSettings:@"" imageToPrint:imageToPrint maxWidth:size.width];
    }
    @catch(PortException *e) {

    }
    @finally
    {
        [SMPort releasePort: _port];
    }
}

-(float) print:(Run *)run row:(int)row section:(int)section pointSize:(float)pointSize {
    if (run.width == 0)
        return 0;
    NSString *textToDraw = [run evaluateWithProvider:_dataSource row:row section:section];
    if ([textToDraw length] == 0)
        return 0;
    UIFont *font = [UIFont systemFontOfSize: run.pointSize == 0 ? pointSize : run.pointSize];
    CGSize measuredSize = [textToDraw sizeWithFont:font constrainedToSize:CGSizeMake(run.width, 200) lineBreakMode:UILineBreakModeWordWrap];
    CGRect rect = CGRectMake([run.xSpec intValue], [self updateY:run.ySpec font:font], run.width, 200);
    [textToDraw drawInRect:rect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment: run.alignment];
    return measuredSize.height;
}

- (float) updateY: (NSString *)ySpec font: (UIFont *)font {
    if ([ySpec length] == 0) {
        //  nothing to do
    }
    else
    if ([ySpec characterAtIndex:0] == '+') {
        int delta = MAX(0, [ySpec characterAtIndex:1] - '0');
        CGSize measuredSize = [@"x" sizeWithFont:font constrainedToSize:CGSizeMake(1000, 200) lineBreakMode:UILineBreakModeWordWrap];
        _y = _y + delta * measuredSize.height;
    }
    else {
        _y = [ySpec floatValue];
    }
    return _y + _tableOffset;
}

- (void)printImageWithPortname:(NSString *)portName portSettings: (NSString*)portSettings imageToPrint: (UIImage*)imageToPrint maxWidth: (int)maxWidth
{
    RasterDocument *rasterDoc = [[RasterDocument alloc] initWithDefaults:RasSpeed_Medium endOfPageBehaviour:RasPageEndMode_FeedAndFullCut endOfDocumentBahaviour:RasPageEndMode_FeedAndFullCut topMargin:RasTopMargin_Standard pageLength:0 leftMargin:0 rightMargin:0];
    StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:imageToPrint :maxWidth :false];

    NSMutableData *commandsToPrint = [[NSMutableData alloc]init];
    NSData *shortcommand = [rasterDoc BeginDocumentCommandData];
    [commandsToPrint appendData:shortcommand];

    shortcommand = [starbitmap getImageDataForPrinting];
    [commandsToPrint appendData:shortcommand];

    shortcommand = [rasterDoc EndDocumentCommandData];
    [commandsToPrint appendData:shortcommand];

    int commandSize = [commandsToPrint length];
    unsigned char *dataToSentToPrinter = (unsigned char*)malloc(commandSize);
    [commandsToPrint getBytes:dataToSentToPrinter];

    SMPort *starPort = nil;
    @try {
        starPort = [SMPort getPort:portName :portSettings :5000];

        if(starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            [Logger Info:@"Fail to open port %@", portName];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                            message:@"Write port timed out"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }

    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                        message:@"Write port timed out"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }

    free(dataToSentToPrinter);
}

@end