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

@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation GraphView

#define DEFAULT_SCALE 10.0

@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize pointInitialized = _pointInitialized;

@synthesize defaults = _defaults;

@synthesize dataSource = _dataSource;

- (CGFloat)scale {
    if (!_scale) {
        NSNumber *savedScale = [self.defaults objectForKey:@"scale"];
        if (savedScale) {
            _scale = savedScale.floatValue;
        } else {
            _scale = DEFAULT_SCALE; // don't allow zero scale
        }
    }
    
    return _scale;
}

- (void)setScale:(CGFloat)scale {
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay]; // any time our scale changes, call for redraw
        
        [self.defaults setObject:[NSNumber numberWithFloat:_scale] forKey:@"scale"];
        [self.defaults synchronize];
    }
}

- (CGPoint)origin {
    if (!self.pointInitialized) {
        NSNumber *savedOriginX = [self.defaults objectForKey:@"originX"];
        NSNumber *savedOriginY = [self.defaults objectForKey:@"originY"];
        
        CGPoint origin;
        if (savedOriginX && savedOriginY) {
            origin = CGPointMake(savedOriginX.floatValue, savedOriginY.floatValue);
        } else {
            origin = CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2, self.bounds.origin.y + self.bounds.size.height / 2);
        }
        
        _origin = origin;
        self.pointInitialized = YES;
    }
    return _origin;
}

- (void)setOrigin:(CGPoint)origin {
    if (origin.x != _origin.x || origin.y != _origin.y) {
        _origin.x = origin.x;
        _origin.y = origin.y;
        [self setNeedsDisplay];
        
        [self.defaults setObject:[NSNumber numberWithFloat:_origin.x] forKey:@"originX"];
        [self.defaults setObject:[NSNumber numberWithFloat:_origin.y] forKey:@"originY"];
        [self.defaults synchronize];
    }
}

- (NSUserDefaults *)defaults {
    if (!_defaults) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return _defaults;
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale;
        gesture.scale = 1;
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        CGPoint newOrigin = self.origin;
        newOrigin.x += translation.x;
        newOrigin.y += translation.y;
        self.origin = newOrigin;
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)tripleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        CGPoint newOrigin = [gesture locationInView:self];
        self.origin = newOrigin;
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
    CGContextBeginPath(context);
    
    // pixel refers to the point's pixel coordinate on screen
    // math refers to the mathematical point
    for (double i = 0; i < self.bounds.size.width * self.contentScaleFactor; i++) {
        double pixelX = i / self.contentScaleFactor;
        double mathX = (pixelX - self.origin.x) / self.scale;
        double mathY = [self.dataSource yValueForGraphView:self
                                             atXCoordinate:mathX];
        double pixelY = self.origin.y - mathY * self.scale;
        
        if ([[self.dataSource drawMode] isEqualToString:@"Line"]) {
            if (i == 0) CGContextMoveToPoint(context, pixelX, pixelY);
            else CGContextAddLineToPoint(context, pixelX, pixelY);
        } else if ([[self.dataSource drawMode] isEqualToString:@"Dot"]) {
            CGContextFillRect(context, CGRectMake(pixelX, pixelY, 1 / self.contentScaleFactor, 1 / self.contentScaleFactor));
        }
    }
    
    CGContextStrokePath(context);
}

@end
