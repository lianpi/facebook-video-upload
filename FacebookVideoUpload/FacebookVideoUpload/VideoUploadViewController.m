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

@synthesize navController = _navController;

- (void)sessionStateChanged:(NSNotification*)notification {
    NSLog(@"Session state changed");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
                               @"1 Test Title", @"title",
                               @"1 Test Description", @"description",
                                  // @"Will Kalish", @"tags",
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

- (IBAction)logoutPressed:(id)sender {
    VideoUploadAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (FBSession.activeSession.isOpen) {
        [appDelegate closeSession];
    }
}


@end
