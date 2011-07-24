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

-(void) prepareForPath:(NSString*)path
{
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[path pathExtension], NULL);
    if (UTTypeConformsTo(uti, kUTTypeImage) || (UTTypeConformsTo(uti, kUTTypeMovie) && UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path))) {
        [paths addObject:path];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    paths = [[NSMutableArray alloc] init];
    
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];

    NSFileManager* mgr = [[[NSFileManager alloc] init] autorelease];
    
    // resource directory
    NSArray* files = [mgr subpathsAtPath:[[NSBundle mainBundle] resourcePath]];
    for (NSString* file in files) {
        [self prepareForPath:[[NSBundle mainBundle] pathForResource:file ofType:@""]];
    }
    
    // document directory
    NSString* dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    files = [mgr subpathsAtPath:dir];
    for (NSString* file in files) {
        [self prepareForPath:[dir stringByAppendingPathComponent:file]];
    }
    
    if ([paths count] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No images or videos" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return YES;
    }

    self.label.text = [NSString stringWithFormat:@"%d/%d", 0, [paths count]];
    
    ALAssetsLibrary* library = [[[ALAssetsLibrary alloc] init] autorelease];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        for (int i = 0; i < [paths count]; i++) {
            NSString* path = [paths objectAtIndex:i];
            
            CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[path pathExtension], NULL);
            if (UTTypeConformsTo(uti, kUTTypeImage)) {
                NSData* d = [NSData dataWithContentsOfFile:path];
                
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    self.imageView.image = [UIImage imageWithData:d]; 
                    self.label.text = [NSString stringWithFormat:@"%d/%d", i + 1, [paths count]]; 
                });
                
                [library writeImageDataToSavedPhotosAlbum:d metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        NSLog(@"%@ (%@)", [error localizedDescription], [path lastPathComponent]);
                    }
                }];
            } else if (UTTypeConformsTo(uti, kUTTypeMovie)) {
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    self.imageView.image = nil; 
                    self.label.text = [NSString stringWithFormat:@"%d/%d", i + 1, [paths count]]; 
                });
                [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:path] completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        NSLog(@"%@ (%@)", [error localizedDescription], [path lastPathComponent]);
                    }
                }];
            }

            if ([path hasPrefix:dir]) {
                [mgr removeItemAtPath:path error:nil];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Completed" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
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
    [paths release];
    [_window release];
    [_imageView release];
    [_label release];
    [super dealloc];
}

@end
