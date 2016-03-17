//
//  CMPopTipView.m
//
//  Portions Copyright (c) 2014 AirWatch, LLC. All Rights Reserved
//  Created by Chris Miles on 18/07/10.
//  Copyright (c) Chris Miles 2010-2011.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CMPopTipView.h"

@interface CMPopTipView ()
@property (nonatomic, retain, readwrite)	id	targetObject;
@end


@implementation CMPopTipView

@synthesize backgroundColor;
@synthesize delegate;
@synthesize message;
@synthesize targetObject;
@synthesize textColor;
@synthesize textFont;
@synthesize textAlignment;
@synthesize animation;
@synthesize maxWidth;

- (void)drawRect:(CGRect)rect {
	
	CGRect bubbleRect;
	if (pointDirection == PointDirectionUp) {
		bubbleRect = CGRectMake(2.0, targetPoint.y+pointerSize, bubbleSize.width, bubbleSize.height);
	}
	else if (pointDirection == PointDirectionDown) {
		bubbleRect = CGRectMake(2.0, targetPoint.y-pointerSize-bubbleSize.height, bubbleSize.width, bubbleSize.height);
	} else {
        bubbleRect = CGRectMake(2.0+pointerSize, targetPoint.y, bubbleSize.width, bubbleSize.height);
    }
	
	CGContextRef c = UIGraphicsGetCurrentContext(); 
	
	CGContextSetRGBStrokeColor(c, 0.0, 0.0, 0.0, 1.0);	// black
	CGContextSetLineWidth(c, 0.0);
    
	CGMutablePathRef bubblePath = CGPathCreateMutable();
	
	if (pointDirection == PointDirectionUp) {
		CGPathMoveToPoint(bubblePath, NULL, targetPoint.x, targetPoint.y);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x+pointerSize, targetPoint.y+pointerSize);
		
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x+bubbleRect.size.width-cornerRadius, bubbleRect.origin.y+bubbleRect.size.height,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height-cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y,
							bubbleRect.origin.x+cornerRadius, bubbleRect.origin.y,
							cornerRadius);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x-pointerSize, targetPoint.y+pointerSize);
	}
	else if (pointDirection == PointDirectionDown) {
		CGPathMoveToPoint(bubblePath, NULL, targetPoint.x, targetPoint.y);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x-pointerSize, targetPoint.y-pointerSize);
		
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height-cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y,
							bubbleRect.origin.x+cornerRadius, bubbleRect.origin.y,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x+bubbleRect.size.width-cornerRadius, bubbleRect.origin.y+bubbleRect.size.height,
							cornerRadius);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x+pointerSize, targetPoint.y-pointerSize);
	}
    else {
        CGPathMoveToPoint(bubblePath, NULL, targetPoint.x+pointerSize, targetPoint.y+bubbleRect.size.height);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x, targetPoint.y+bubbleRect.size.height/2.0);
   		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x+pointerSize, targetPoint.y);      
        
		CGPathMoveToPoint(bubblePath, NULL, targetPoint.x+pointerSize, targetPoint.y);
		
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width-pointerSize, bubbleRect.origin.y,
							bubbleRect.origin.x+bubbleRect.size.width-pointerSize, bubbleRect.origin.y+cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width-pointerSize, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x+bubbleRect.size.width-cornerRadius-pointerSize, bubbleRect.origin.y+bubbleRect.size.height,
							cornerRadius);
        CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x+pointerSize, bubbleRect.origin.y+bubbleRect.size.height);
    }
    
	CGPathCloseSubpath(bubblePath);
    
	
	// Draw shadow
	CGContextAddPath(c, bubblePath);
    CGContextSaveGState(c);
	CGContextSetShadow(c, CGSizeMake(0, 3), 5);
	CGContextSetRGBFillColor(c, 0.0, 0.0, 0.0, 0.9);
	CGContextFillPath(c);
    CGContextRestoreGState(c);
    
	
	// Draw clipped background gradient
	CGContextAddPath(c, bubblePath);
	CGContextClip(c);
	
	CGFloat bubbleMiddle = (bubbleRect.origin.y+(bubbleRect.size.height/2)) / self.bounds.size.height;
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorSpace;
	size_t locationCount = 5;
	CGFloat locationList[] = {0.0, bubbleMiddle-0.03, bubbleMiddle, bubbleMiddle+0.03, 1.0};
    
	CGFloat colourHL = 0.0;
	if (highlight) {
		colourHL = 0.25;
	}
	
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	CGFloat alpha;
	size_t numComponents = CGColorGetNumberOfComponents([backgroundColor CGColor]);
	const CGFloat *components = CGColorGetComponents([backgroundColor CGColor]);
	if (numComponents == 2) {
		red = components[0];
		green = components[0];
		blue = components[0];
		alpha = components[1];
	}
	else {
		red = components[0];
		green = components[1];
		blue = components[2];
		alpha = components[3];
	}
	CGFloat colorList[] = {
		//red, green, blue, alpha 
		red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
		red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
		red*1.08+colourHL, green*1.08+colourHL, blue*1.08+colourHL, alpha,
		red     +colourHL, green     +colourHL, blue     +colourHL, alpha,
		red     +colourHL, green     +colourHL, blue     +colourHL, alpha
	};
	//	CGFloat colorList[] = {
    //		//red, green, blue, alpha 
    //		154.0/255.0, 94.0/255.0, 130.0/255.0, 1.0,
    //		154.0/255.0, 94.0/255.0, 130.0/255.0, 1.0,
    //		144.0/255.0, 84.0/255.0, 120.0/255.0, 1.0,
    //		134.0/255.0, 74.0/255.0, 110.0/255.0, 1.0,
    //		134.0/255.0, 74.0/255.0, 110.0/255.0, 1.0
    //	};
	myColorSpace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents(myColorSpace, colorList, locationList, locationCount);
	CGPoint startPoint, endPoint;
	startPoint.x = 0;
	startPoint.y = 0;
	endPoint.x = 0;
	endPoint.y = CGRectGetMaxY(self.bounds);
	
	CGContextDrawLinearGradient(c, myGradient, startPoint, endPoint,0);
	CGGradientRelease(myGradient);
	CGColorSpaceRelease(myColorSpace);
	
	CGContextSetRGBStrokeColor(c, 0.4, 0.4, 0.4, 1.0);
	CGContextAddPath(c, bubblePath);
	CGContextDrawPath(c, kCGPathStroke);
	
	CGPathRelease(bubblePath);
	
	// Draw text
	[textColor set];
	CGRect textFrame = CGRectMake(bubbleRect.origin.x - pointerSize/2,
								  bubbleRect.origin.y + cornerRadius,
								  bubbleRect.size.width - cornerRadius,
								  bubbleRect.size.height - cornerRadius*2);
	[self.message drawInRect:textFrame
					withFont:textFont
			   lineBreakMode:NSLineBreakByWordWrapping
				   alignment:self.textAlignment];
}

- (void)presentPointingAtView:(UIView *)targetView inView:(UIView *)containerView animated:(BOOL)animated {
	if (!self.targetObject) {
		self.targetObject = targetView;
	}
	
	[containerView addSubview:self];
    
	// Size of rounded rect
	CGFloat rectWidth;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // iPad
        if (maxWidth) {
            if (maxWidth < containerView.frame.size.width) {
                rectWidth = maxWidth;
            }
            else {
                rectWidth = containerView.frame.size.width - 20;
            }
        }
        else {
            rectWidth = (int)(containerView.frame.size.width/3);
        }
    }
    else {
        // iPhone
        if (maxWidth) {
            if (maxWidth < containerView.frame.size.width) {
                rectWidth = maxWidth;
            }
            else {
                rectWidth = containerView.frame.size.width - 10;
            }
        }
        else {
            rectWidth = (int)(containerView.frame.size.width*2/3);
        }
    }

	CGSize textSize = [self.message sizeWithFont:textFont
							   constrainedToSize:CGSizeMake(rectWidth, 99999.0)
								   lineBreakMode:NSLineBreakByWordWrapping];
	bubbleSize = CGSizeMake(textSize.width + cornerRadius*2 + pointerSize*2, textSize.height + cornerRadius*2);

	CGFloat pointerY;	// Y coordinate of pointer target (within containerView)
    
    CGPoint targetOriginInContainer = [targetView convertPoint:CGPointMake(0.0, 0.0) toView:containerView];    
    pointerY = targetOriginInContainer.y;
    pointDirection = PointDirectionDown;
	
	CGFloat W = containerView.frame.size.width;
	
	CGPoint p = [targetView.superview convertPoint:targetView.center toView:containerView];
	CGFloat x_p = p.x;
	CGFloat x_b = x_p - roundf(bubbleSize.width/2);
	if (x_b < sidePadding) {
		x_b = sidePadding;
	}
	if (x_b + bubbleSize.width + sidePadding > W) {
		x_b = W - bubbleSize.width - sidePadding;
	}
	if (x_p - pointerSize < x_b + cornerRadius) {
		x_p = x_b + cornerRadius + pointerSize;
	}
	if (x_p + pointerSize > x_b + bubbleSize.width - cornerRadius) {
		x_p = x_b + bubbleSize.width - cornerRadius - pointerSize;
	}
	
	CGFloat fullHeight = bubbleSize.height + pointerSize + 10.0;
	CGFloat y_b;
	if (pointDirection == PointDirectionUp) {
		y_b = topMargin + pointerY;
		targetPoint = CGPointMake(x_p-x_b, 0);
	}
	else if (pointDirection == PointDirectionDown) {
		y_b = pointerY - fullHeight;
		targetPoint = CGPointMake(x_p-x_b, fullHeight-2.0);
	} else {
        y_b = topMargin + pointerY;
		targetPoint = CGPointMake(0, 0);
    }
    
    if(W > 703) { // Portrait
        x_b = targetView.frame.size.width + 75.0f;
    } else {
        x_b = 25.0f;
    }
	
	CGRect finalFrame = CGRectMake(x_b-sidePadding,
								   y_b,
								   bubbleSize.width+sidePadding*2,
								   fullHeight);
    
   	
	if (animated) {
        if (animation == CMPopTipAnimationSlide) {
            self.alpha = 0.0;
            CGRect startFrame = finalFrame;
            startFrame.origin.y += 10;
            self.frame = startFrame;
        }
		else if (animation == CMPopTipAnimationPop) {
            self.frame = finalFrame;
            self.alpha = 0.5;
            
            // start a little smaller
            self.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
            
            // animate to a bigger size
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(popAnimationDidStop:finished:context:)];
            [UIView setAnimationDuration:0.15f];
            self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
            self.alpha = 1.0;
            [UIView commitAnimations];
        }
		
		[self setNeedsDisplay];
		
		if (animation == CMPopTipAnimationSlide) {
			[UIView beginAnimations:nil context:nil];
			self.alpha = 1.0;
			self.frame = finalFrame;
			[UIView commitAnimations];
		}
	}
	else {
		// Not animated
		[self setNeedsDisplay];
		self.frame = finalFrame;
	}
}

- (void)presentPointingAtBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated {
	UIView *targetView = (UIView *)[barButtonItem performSelector:@selector(view)];
	UIView *targetSuperview = [targetView superview];
	UIView *containerView = nil;
	if ([targetSuperview isKindOfClass:[UINavigationBar class]]) {
		UINavigationController *navController = (UINavigationController *)[(UINavigationBar *)targetSuperview delegate];
		containerView = [[navController topViewController] view];
	}
	else if ([targetSuperview isKindOfClass:[UIToolbar class]]) {
		containerView = [targetSuperview superview];
	}
	
	if (nil == containerView) {
		self.targetObject = nil;
		return;
	}
	
	self.targetObject = barButtonItem;
	
	[self presentPointingAtView:targetView inView:containerView animated:animated];
}

- (void)finaliseDismiss {
	[self removeFromSuperview];
	self.targetObject = nil;
}

- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self finaliseDismiss];
}

- (void)dismissAnimated:(BOOL)animated {
	
	if (animated) {
		CGRect frame = self.frame;
		frame.origin.y += 10.0;
		
		[UIView beginAnimations:nil context:nil];
		self.alpha = 0.0;
		self.frame = frame;
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
	else {
		[self finaliseDismiss];
	}
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { 
	highlight = YES;
	[self setNeedsDisplay];
	
	[self dismissAnimated:YES];
	
	if (delegate && [delegate respondsToSelector:@selector(popTipViewWasDismissedByUser:)]) {
		[delegate popTipViewWasDismissedByUser:self];
	}
}

- (void)popAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // at the end set to normal size
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1f];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.opaque = NO;
		
		cornerRadius = 10.0;
		topMargin = 2.0;
		pointerSize = 12.0;
		sidePadding = 2.0;
		
        self.textFont = [UIFont fontWithName:@"Helvetica" size:14.0f];
		self.textColor = [UIColor whiteColor];
		self.textAlignment = NSTextAlignmentCenter;
		self.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:60.0/255.0 blue:154.0/255.0 alpha:1.0];
        self.animation = CMPopTipAnimationSlide;
    }
    return self;
}

- (PointDirection) getPointDirection {
  return pointDirection;
}

- (id)initWithMessage:(NSString *)messageToShow {
	CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame])) {
		self.message = messageToShow;
	}
	return self;
}

@end
