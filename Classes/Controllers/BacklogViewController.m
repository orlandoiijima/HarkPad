//
//  BacklogViewController.m
//  HarkPad
//
//  Created by Willem Bison on 06-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "BacklogViewController.h"
#import "Service.h"
#import "Backlog.h"

@implementation BacklogViewController

@synthesize backlog;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        backlog = [[Service getInstance] getBacklogStatistics];
        float marginTop = 20;
        float marginLeft = 20;
        float x;
        float y = marginTop;
        float cellWidth = 30;
        float labelWidth = 150;
        float lineHeight = 20;
        NSMutableDictionary *courseTotals = [[NSMutableDictionary alloc] init];
        for(Backlog *line in backlog)
        {
            x = marginLeft;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, labelWidth, lineHeight)];
            [self.view addSubview:label];
            label.text = line.product.key;
            x += labelWidth;
            int productTotal = 0;
            
            for(int i = 0; i < 6; i++)
            {
                label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, cellWidth, lineHeight)];
                label.textAlignment = UITextAlignmentRight;
                [self.view addSubview:label];
                NSString *key = [NSString stringWithFormat:@"%d", i];
                NSNumber *count = [line.totals objectForKey:key];
                label.text = count == nil ? @"-" : [count stringValue];
                productTotal += [count intValue];
                x += cellWidth;
                int courseTotal = [count intValue]+[[courseTotals objectForKey:key] intValue];
                [courseTotals setObject:[NSNumber numberWithInt:courseTotal] forKey:key];
            }
            label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, cellWidth, lineHeight)];
            label.textAlignment = UITextAlignmentRight;
            [self.view addSubview:label];
            label.text = [NSString stringWithFormat:@"%d", productTotal];
            label.textColor = [UIColor blueColor];
            y += lineHeight;
        }
        x = marginLeft + labelWidth;
        int productTotal = 0;
        for(int i = 0; i < 6; i++)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, cellWidth, lineHeight)];
            label.textAlignment = UITextAlignmentRight;
            [self.view addSubview:label];
            NSString *key = [NSString stringWithFormat:@"%d", i];
            NSNumber *count = [courseTotals objectForKey:key];
            label.text = [count stringValue];
            label.textColor = [UIColor blueColor];
            x += cellWidth;
            productTotal += [count intValue];
        }
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, cellWidth, lineHeight)];
        label.textAlignment = UITextAlignmentRight;
        [self.view addSubview:label];
        label.text = [NSString stringWithFormat:@"%d", productTotal];
        label.textColor = [UIColor blueColor];

        self.contentSizeForViewInPopover = CGSizeMake(labelWidth + (6+1) * cellWidth + 2*marginLeft, ([backlog count]+1) * lineHeight + 2*marginTop);
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
