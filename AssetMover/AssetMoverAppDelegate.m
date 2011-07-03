//
//  AssetMoverAppDelegate.m
//  AssetMover
//
//  Created by 伊藤 啓 on 11/07/04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AssetMoverAppDelegate.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation AssetMoverAppDelegate


@synthesize window=_window;
@synthesize imageView = _imageView;
@synthesize label = _label;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSFileManager* mgr = [[[NSFileManager alloc] init] autorelease];
        NSArray* files = [mgr subpathsAtPath:[[NSBundle mainBundle] resourcePath]];
        __block int cnt = 0;
        for (NSString* file in files) {
            CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[file pathExtension], NULL);
            if (UTTypeConformsTo(uti, kUTTypeImage)) {
                NSData* d = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:@""]];
                
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    self.imageView.image = [UIImage imageWithData:d]; 
                    self.label.text = [NSString stringWithFormat:@"%d", ++cnt];
                });
                
                [[[[ALAssetsLibrary alloc] init] autorelease] writeImageDataToSavedPhotosAlbum:d metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                }];
            }
        }
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_imageView release];
    [_label release];
    [super dealloc];
}

@end
