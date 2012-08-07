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

- (void)setProgramDescription:(NSString *)description {
    self.navigationItem.title = description;
}

- (void)setGraphView:(GraphView *)graphView {
    _graphView = graphView;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    UITapGestureRecognizer * tripleTap = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tripleTap:)];
    tripleTap.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tripleTap];
    self.graphView.dataSource = self;
}

- (float)yValueForGraphView:(GraphView *)sender
              atXCoordinate:(float)x
{
    NSDictionary *xValue = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:x], @"x", nil];
    return [CalculatorBrain runProgram:self.programStack usingVariableValues:xValue];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
@end
