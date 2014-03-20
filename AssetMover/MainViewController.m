//
//  MainViewController.m
//  AssetMover
//
//  Created by itok on 2014/02/27.
//
//

#import "MainViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>

@interface MainViewController ()
{
	ALAssetsLibrary* library;
	NSInteger index;
	NSInteger total;
    
    NSMutableArray* paths;
    NSDateFormatter* dateFormatter;
    
    NSString* docDir;
}

@property (weak, nonatomic) IBOutlet UISwitch *dateSw;
@property (weak, nonatomic) IBOutlet UITextField *dateFld;
@property (weak, nonatomic) IBOutlet UISwitch *locationSw;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    paths = [NSMutableArray array];

    dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)import:(id)sender
{
    [paths removeAllObjects];
    
    NSFileManager* mgr = [NSFileManager defaultManager];
    NSArray* files = [mgr subpathsAtPath:[[NSBundle mainBundle] resourcePath]];
    for (NSString* file in files) {
        [self prepareForPath:[[NSBundle mainBundle] pathForResource:file ofType:@""]];
    }
    
    // document directory
    docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    files = [mgr subpathsAtPath:docDir];
    for (NSString* file in files) {
        [self prepareForPath:[docDir stringByAppendingPathComponent:file]];
    }
    
    if ([paths count] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No images or videos" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    total = [paths count];
    self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", 0, (int)total];

    library = [[ALAssetsLibrary alloc] init];
	index = 0;
	[self performSelector:@selector(importNext) withObject:nil afterDelay:0];
}

-(void) prepareForPath:(NSString*)path
{
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    if (UTTypeConformsTo(uti, kUTTypeImage) || (UTTypeConformsTo(uti, kUTTypeMovie) && UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path))) {
        [paths addObject:path];
    }
}

-(void) importNext
{
	if ([paths count] == 0) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Completed" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	NSString* path = [paths objectAtIndex:0];
	
	CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
	if (UTTypeConformsTo(uti, kUTTypeImage)) {
		NSData* d = [NSData dataWithContentsOfFile:path];
		
		self.imageView.image = [UIImage imageWithData:d];
		self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", (int)index + 1, (int)total];
		
        
        NSMutableDictionary* metadata = [NSMutableDictionary dictionary];
        if ([self.dateSw isOn]) {
            int range = (int)[self.dateFld.text integerValue];
            if (range == 0) {
                range = 30;
            }
            NSDate* date = [NSDate dateWithTimeIntervalSinceNow:-(int)arc4random_uniform((int)60*60*24*range)];
            NSString* str = [dateFormatter stringFromDate:date];
            [metadata setObject:@{(id)kCGImagePropertyExifDateTimeOriginal: str, (id)kCGImagePropertyExifDateTimeDigitized: str} forKey:(id)kCGImagePropertyExifDictionary];
            [metadata setObject:@{(id)kCGImagePropertyTIFFDateTime: str} forKey:(id)kCGImagePropertyTIFFDictionary];
        }
		
		[library writeImageDataToSavedPhotosAlbum:d metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
			if (error) {
				NSLog(@"%@ (%@)", [error localizedDescription], [path lastPathComponent]);
			}
			[self performSelectorOnMainThread:@selector(importNext) withObject:nil waitUntilDone:NO];
		}];
	} else if (UTTypeConformsTo(uti, kUTTypeMovie)) {
		self.imageView.image = nil;
		self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", (int)index + 1, (int)total];
        
		[library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:path] completionBlock:^(NSURL *assetURL, NSError *error) {
			if (error) {
				NSLog(@"%@ (%@)", [error localizedDescription], [path lastPathComponent]);
			}
			[self performSelectorOnMainThread:@selector(importNext) withObject:nil waitUntilDone:NO];
		}];
	}
	
	[paths removeObjectAtIndex:0];
	index ++;
	
	if ([path hasPrefix:docDir]) {
        // document directory
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
}

@end
