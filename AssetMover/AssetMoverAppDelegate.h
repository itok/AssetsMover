//
//  AssetMoverAppDelegate.h
//  AssetMover
//
//  Created by 伊藤 啓 on 11/07/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetMoverAppDelegate : NSObject <UIApplicationDelegate> {

    UIImageView *_imageView;
    UILabel *_label;
    
    NSMutableArray* paths;
    NSUInteger count;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *label;

@end
