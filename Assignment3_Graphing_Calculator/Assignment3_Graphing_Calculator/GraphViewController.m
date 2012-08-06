//
//  GraphViewController.m
//  Assignment3_Graphing_Calculator
//
//  Created by Cheng Bocong on 12/08/06.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource>

@property (nonatomic, weak) IBOutlet GraphView *graphView;

@end

@implementation GraphViewController

@synthesize programStack = _programStack;
@synthesize graphView = _graphView;

- (void)setProgramStack:(NSArray *)programStack {
    _programStack = programStack;
    [self.graphView setNeedsDisplay];
}

- (float)yValueForXCoordinate:(float)x
                 forGraphView:(GraphView *)sender {
    NSDictionary *xValue = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:x], @"x", nil];
    NSLog(@"%@", xValue);
    return [CalculatorBrain runProgram:self.programStack usingVariableValues:xValue];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
