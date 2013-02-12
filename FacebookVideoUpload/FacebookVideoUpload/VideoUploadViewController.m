//
//  VideoUploadViewController.m
//  FacebookVideoUpload
//
//  Created by Will on 2/12/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "VideoUploadViewController.h"
#import "VideoUploadAppDelegate.h"

@interface VideoUploadViewController ()
@property (strong, nonatomic) UINavigationController* navController;
@end

@implementation VideoUploadViewController

//@synthesize facebook = _facebook;
//@synthesize facebook;
@synthesize navController = _navController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //facebook = [[Facebook alloc] initWithAppId:@"537815409585422" andDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buttonClicked:(id)sender
{
    VideoUploadAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    [appDelegate openSessionWithAllowLoginUI:YES];
    
    //Post video
    /*
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *videoDirectory = [[[fileManager  URLsForDirectory:NSMoviesDirectory inDomains:NSUserDomainMask] objectAtIndex:0] path];
    NSArray *videoFiles = [fileManager contentsOfDirectoryAtPath:videoDirectory error:nil];
    NSLog(@"Videos: %@", videoFiles);
     */
    
    //replace with video data in iGotYa
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mov"]; 
    NSData *videoData = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               videoData, @"video.mov",
                               @"video/quicktime", @"contentType",
                               @"Video Test Title", @"title",
                               @"Video Test Description", @"description",
                               nil];

    FBRequest *uploadRequest = [FBRequest requestWithGraphPath:@"me/videos"
                                                parameters:params
                                                HTTPMethod:@"POST"];
    [uploadRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if(!error){
            NSLog(@"Done: %@", result);
        }
        else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
    
}


@end
