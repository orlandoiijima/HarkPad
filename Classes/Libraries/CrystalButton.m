//
//  CrystalButton.m
//  Created by Juani on 29/03/11.
//
//  Copyright 2011 Agile Route. All rights reserved.
//	http://www.agileroute.com
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//    * Neither the name of the <organization> nor the
//    names of its contributors may be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//    ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//    DISCLAIMED. IN NO EVENT SHALL FABIAN CANAS BE LIABLE FOR ANY
//    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "CrystalButton.h"
#import "UIColor-Expanded.h"

@implementation CrystalButton

//This changes the width of the stroke around the button
#define BORDER_WIDTH	1.0f
//This defines the radius of the button's rounded corners
#define CORNER_RADIUS	7.0f

//We set the opacity of the button (not including the text) to 0.9 if the button is enabled 
//or 0.4 if the button is disabled. You can change this if you wish.
#define OPACITY_ENABLED 0.9f
#define OPACITY_DISABLED 0.4F

- (void)setupGradient
{
	CGFloat h, s, b, a;

	[tintColor hue:&h saturation:&s brightness:&b alpha:&a];
	
	//The outer stroke uses the pure color
	gradientLayer.borderColor = tintColor.CGColor;

	//We build a gradient to fill the button's inside
	gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHue:h saturation:0.0f brightness:1.0f alpha:a].CGColor,
							(id)[UIColor colorWithHue:h saturation:(s - MAX(0.0f, (s - 0.1f) * 0.25f)) brightness:(b + MAX(0.0f, (0.9f - b) * 0.25f)) alpha:a].CGColor,
							(id)tintColor.CGColor,
							(id)[UIColor colorWithHue:h saturation:(s - MAX(0.0f, (s - 0.1f) * 0.2f)) brightness:(b + MAX(0.0f, (0.9f - b) * 0.2f)) alpha:a].CGColor,
							nil];
	
	gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],
							   [NSNumber numberWithFloat:0.5f],
							   [NSNumber numberWithFloat:0.5f],
							   [NSNumber numberWithFloat:1.0f],
							   nil];
}


- (void)addLayers
{
	//We mix the layers to obtain the desired effect
	gradientLayer = [[CAGradientLayer alloc] init];
	gradientLayer.cornerRadius = CORNER_RADIUS;
	gradientLayer.borderWidth = BORDER_WIDTH;
	
	//If it is supported under this iOS version, we put a shadow under it
	if ([gradientLayer respondsToSelector:@selector(setShadowColor:)])
	{
		gradientLayer.shadowColor = [UIColor blackColor].CGColor;
		gradientLayer.shadowOffset = CGSizeMake(0.0f, 1.0f);
		gradientLayer.shadowOpacity = 0.50f;
		gradientLayer.shadowRadius = 1.5f;
	}
	
	//We set the opacity
	gradientLayer.opacity = (self.enabled) ? OPACITY_ENABLED : OPACITY_DISABLED;
	
	//We draw the button taking into account the borders and the shadow
	[gradientLayer setFrame:CGRectMake(4.0f, 2.0f, self.frame.size.width - 8.0f, self.frame.size.height - 7.0f)];
	[self.layer insertSublayer:gradientLayer below:[self.layer.sublayers lastObject]];
	
	//If the button is highlighted (e.g.: pressed) we draw it
	highlightLayer = [[CALayer alloc] init];
	highlightLayer.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f].CGColor;
	highlightLayer.cornerRadius = CORNER_RADIUS;
	[highlightLayer setFrame:CGRectMake(4.0f, 2.0f, self.frame.size.width - 8.0f, self.frame.size.height - 7.0f)];
	
	if (self.highlighted)
		[self.layer insertSublayer:highlightLayer below:[self.layer.sublayers lastObject]];
}


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame])
	{
		//The button defaults to Blue with transparent background
		self.backgroundColor = [UIColor clearColor];
		[self addLayers];
		self.tintColor = [UIColor blueColor];
    }
	
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder])
	{
		//The button defaults to Blue with transparent background
		self.backgroundColor = [UIColor clearColor];
		[self addLayers];
		self.tintColor = [UIColor blackColor];
    }

    return self;
}


- (void)setEnabled:(BOOL)value {
	[super setEnabled:value];
	
	gradientLayer.opacity = (value) ? OPACITY_ENABLED : OPACITY_DISABLED;
}


- (void)setHighlighted:(BOOL)value {
	[super setHighlighted:value];

	if (!value)
		[highlightLayer removeFromSuperlayer];
	else if (highlightLayer.superlayer == nil)
		[self.layer insertSublayer:highlightLayer above:gradientLayer];
}


- (UIColor *)tintColor {
	return tintColor;
}


- (void)setTintColor:(UIColor *)value {
	if (tintColor != value)
	{
		tintColor = value;
		[self setupGradient];
	}
}

- (void)setBounds:(CGRect)rect {
	[super setBounds:rect];

	[gradientLayer setBounds:CGRectMake(4.0f, 2.0f, self.bounds.size.width - 8.0f, self.bounds.size.height - 7.0f)];
	[highlightLayer setBounds:CGRectMake(4.0f, 2.0f, self.bounds.size.width - 8.0f, self.bounds.size.height - 7.0f)];
}

- (void)setFrame:(CGRect)rect {
	[super setFrame:rect];

	[gradientLayer setFrame:CGRectMake(4.0f, 2.0f, self.frame.size.width - 8.0f, self.frame.size.height - 7.0f)];
	[highlightLayer setFrame:CGRectMake(4.0f, 2.0f, self.frame.size.width - 8.0f, self.frame.size.height - 7.0f)];
}

@end
