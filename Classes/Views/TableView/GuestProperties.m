//
//  Created by wbison on 28-01-12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "GuestProperties.h"
#import "UIImage+Tint.h"

@implementation GuestProperties {
}

@synthesize guest = _guest, delegate = _delegate, viewFemale, viewMale, viewEmpty, isHostView;

+ (GuestProperties *)viewWithGuest: (Guest *)guest frame: (CGRect)frame delegate: (id)delegate
{
    GuestProperties *view = [[GuestProperties alloc] initWithFrame:frame];
    view.clipsToBounds = YES;

    view.guest = guest;

    view.delegate = delegate;
    
    UIImage *maleImage = [[UIImage imageNamed:@"user.png"] imageTintedWithColor: [UIColor blueColor]];
    view.viewMale = [ToggleButton buttonWithTitle:NSLocalizedString(@"Male", nil) image: maleImage frame:CGRectMake(15, 15, 0, 0)];
    view.viewMale.isOn = guest.isMale;
    [view.viewMale addTarget:delegate action:@selector(tapGender:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:view.viewMale];

    UIImage *femaleImage = [[UIImage imageNamed:@"user.png"] imageTintedWithColor: [UIColor colorWithRed:1.0 green:105/255.0 blue:180/255.0 alpha:1]];
    view.viewFemale = [ToggleButton buttonWithTitle:NSLocalizedString(@"Female", nil) image: femaleImage frame:CGRectMake(15 + view.viewMale.bounds.size.width + 10, 15, 0, 0)];
    view.viewFemale.isOn = guest.isMale == NO;
    [view.viewFemale addTarget:delegate action:@selector(tapGender:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:view.viewFemale];

    UIImage *emptyImage = [[UIImage imageNamed:@"user.png"] imageTintedWithColor: [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3]];
    view.viewEmpty = [ToggleButton buttonWithTitle:NSLocalizedString(@"Empty", nil) image: emptyImage frame:CGRectMake(view.viewFemale.frame.origin.x + view.viewFemale.bounds.size.width + 10, 15, 0, 0)];
    view.viewEmpty.isOn = guest == nil;
    [view.viewEmpty addTarget:delegate action:@selector(tapGender:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:view.viewEmpty];

    view.isHostView  = [ToggleButton buttonWithTitle:NSLocalizedString(@"Host", nil) image:[UIImage imageNamed:@"BlueStar.png"] frame:CGRectMake(15, 55, 0, 0)];
    view.isHostView.isOn = guest.isHost;
    [view.isHostView addTarget:delegate action:@selector(tapHost:) forControlEvents:UIControlEventTouchDown];
    [view addSubview: view.isHostView];

    NSArray *diets = [NSArray arrayWithObjects:
        NSLocalizedString(@"Gluten allergy", nil),
        NSLocalizedString(@"Nut allergy", nil),
        NSLocalizedString(@"Lactose intolerance", nil),
        NSLocalizedString(@"Milk allergy", nil),
        NSLocalizedString(@"Halal", nil),
        NSLocalizedString(@"Kosher", nil),
        NSLocalizedString(@"Montignac", nil),
        NSLocalizedString(@"No meat", nil),
        NSLocalizedString(@"No fish", nil),
        NSLocalizedString(@"Salt free", nil),
        nil];
    int i = 0;
    for(NSString *diet in diets) {
        ToggleButton *toggle = [ToggleButton buttonWithTitle:NSLocalizedString([diets objectAtIndex:i], nil) image: [UIImage imageNamed:@"errorRedDot.png"] frame:CGRectZero];
        [toggle addTarget:delegate action:@selector(tapDiet:) forControlEvents:UIControlEventTouchDown];
        [view addSubview:toggle];
        toggle.tag = 1 << i;
        i++;
    }

    return view;
}

- (void)setFrame:(CGRect)aFrame {
    [super setFrame:aFrame];
    CALayer *layer = [self.layer.sublayers objectAtIndex:0];
    if (layer == nil) return;
    layer.frame = self.bounds;
}

- (void) setGuest: (Guest *)guest {
    for(int i=0; i < 20; i++) {
        ToggleButton *toggle = [self viewWithTag:1 << i];
        if (toggle != nil)
            toggle.isOn = guest != nil && guest.diet & (1 << i);
    }
    viewMale.isOn = guest != nil && guest.isMale;
    viewFemale.isOn = guest != nil && !guest.isMale;
    viewEmpty.isOn = guest == nil || guest.isEmpty;
    isHostView.isOn = guest != nil && guest.isHost;
}

- (void) layoutSubviews {
    CGFloat x = 15,y = 95;
    int firstAtLine = 0;
    for(int i = 0; i < 10; i++) {
        ToggleButton *toggle = (ToggleButton *) [self viewWithTag: 1 << i];
        if (toggle == nil) break;
        if (x + toggle.bounds.size.width + 10 > self.bounds.size.width) {
            CGFloat extraSpace = (self.bounds.size.width - x) / (i - firstAtLine );
            x = 15;
            for(int j = firstAtLine; j < i; j++) {
                ToggleButton *toggle = (ToggleButton *)[self viewWithTag: 1 << j];
                toggle.frame = CGRectMake(x, y, toggle.bounds.size.width + extraSpace, toggle.bounds.size.height);
                x += toggle.frame.size.width + 10;
            }
            x = 15;
            y += toggle.bounds.size.height + 5;
            firstAtLine = i;
        }
        toggle.frame = CGRectMake(x, y, toggle.bounds.size.width, toggle.bounds.size.height);
        x += toggle.bounds.size.width + 10;
    }
}


@end