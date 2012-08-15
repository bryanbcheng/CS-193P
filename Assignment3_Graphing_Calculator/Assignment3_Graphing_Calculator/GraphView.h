//
//  GraphView.h
//  Assignment3_Graphing_Calculator
//
//  Created by Cheng Bocong on 12/08/06.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource <NSObject>
- (float)yValueForGraphView:(GraphView *)sender
              atXCoordinate:(float)x;
- (NSString *)drawMode;
@end

@interface GraphView : UIView

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)pan:(UIPanGestureRecognizer *)gesture;
- (void)tripleTap:(UITapGestureRecognizer *)gesture;

@end
