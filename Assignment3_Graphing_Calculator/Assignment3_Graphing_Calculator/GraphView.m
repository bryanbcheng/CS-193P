//
//  GraphView.m
//  Assignment3_Graphing_Calculator
//
//  Created by Cheng Bocong on 12/08/06.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@interface GraphView()

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@property (nonatomic) BOOL pointInitialized;

@end

@implementation GraphView

#define DEFAULT_SCALE 10.0

@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize pointInitialized = _pointInitialized;

@synthesize dataSource = _dataSource;

- (CGFloat)scale {
    if (!_scale) {
        return DEFAULT_SCALE; // don't allow zero scale
    } else {
        return _scale;
    }
}

- (void)setScale:(CGFloat)scale {
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay]; // any time our scale changes, call for redraw
    }
}

- (CGPoint)origin {
    if (!self.pointInitialized) {
        CGPoint origin = CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2, self.bounds.origin.y + self.bounds.size.height / 2);
        
        _origin = origin;
    }
    return _origin;
}

- (void)setOrigin:(CGPoint)origin {
    if (origin.x != _origin.x || origin.y != _origin.y) {
        _origin.x = origin.x;
        _origin.y = origin.y;
        [self setNeedsDisplay];
    }
}

- (void)setup {
    self.contentMode = UIViewContentModeRedraw; // if our bounds changes, redraw ourselves
}

- (void)awakeFromNib {
    [self setup]; // get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Draw axes
    [AxesDrawer drawAxesInRect:self.bounds
                 originAtPoint:self.origin
                         scale:self.scale];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    //CGContextBeginPath(context);
    
    NSLog(@"%g %g", self.bounds.size.width, self.contentScaleFactor);
    // pixel refers to the point's pixel coordinate on screen
    // math refers to the mathematical point
    for (double i = 0; i < self.bounds.size.width * self.contentScaleFactor; i++) {
        double pixelX = i / self.contentScaleFactor;
        double mathX = (pixelX - self.origin.x) / self.scale;
        double mathY = [self.dataSource yValueForXCoordinate:mathX
                                 forGraphView:self];
        double pixelY = self.origin.y - mathY * self.scale;
        if (i == 0) CGContextMoveToPoint(context, pixelX, pixelY);
        else CGContextAddLineToPoint(context, pixelX, pixelY);
        //NSLog(@"%g %g %g %g", pixelX, pixelY, mathX, mathY);
    }
    
    CGContextStrokePath(context);
}

@end
