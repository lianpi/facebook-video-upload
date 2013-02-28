//
//  VideoUploadViewController.m
//  FacebookVideoUpload
//
//  Created by Will on 2/12/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "VideoUploadViewController.h"
#import "VideoUploadAppDelegate.h"

@interface VideoUploadViewController () <FBFriendPickerDelegate>
@property (strong, nonatomic) UINavigationController* navController;
@property (nonatomic, strong) NSArray *selectedFriends;  //the items in the array are <FBGraphUser> objects
@property (nonatomic) BOOL sessionIsOpen;
@property (nonatomic, strong) NSDictionary *userFBInfo;
@end

@implementation VideoUploadViewController

@synthesize navController = _navController;
@synthesize selectedFriends = _selectedFriends;
@synthesize sessionIsOpen = _sessionIsOpen;
@synthesize userFBInfo= _userFBInfo;

- (NSArray *)selectedFriends{
    if(!_selectedFriends){
        _selectedFriends = [[NSArray alloc] init];
    }
    return _selectedFriends;
}

- (NSDictionary *)userFBInfo
{
    if(!_userFBInfo){
        _userFBInfo = [[NSDictionary alloc] init];
    }
    return _userFBInfo;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
}

- (void)sessionStateChanged:(NSNotification*)notification {
    //NSLog(@"Session state changed: %@", notification);
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
    
    //make sure open session is availible
    VideoUploadAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)displayFriendPickerController
{
    NSLog(@"Tag called");
    // Initialize the friend picker
    FBFriendPickerViewController *friendPickerController = [[FBFriendPickerViewController alloc] init];
    // Set the friend picker title
    friendPickerController.title = @"Tag Friends In Video";
    
    // TODO: Set up the delegate to handle picker callbacks, ex: Done/Cancel button
    friendPickerController.delegate = self;
    
    // Load the friend data
    [friendPickerController loadData];
    // Show the picker modally
    [friendPickerController presentModallyFromViewController:self animated:YES handler:(FBModalCompletionHandler)^{
        //when friendPickerController is done call function
        [self postVideoAndTag];
        //[self getUserFBInfo];
    }];
}

//getUserFBInfo currently not being used for anything
//can be used to get the Facebook info of the person using the app
- (void)getUserFBInfo
{
    FBRequest *myInfo = [FBRequest requestForMe];
    [myInfo startWithCompletionHandler:^(FBRequestConnection *infoConnection, id infoResult, NSError *infoError) {
        if(!infoError){
            NSLog(@"My info done: %@", infoResult);
            
            NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:self.selectedFriends];
            [temp addObject:infoResult];
            self.selectedFriends = [temp copy];
            //NSLog(@"Tagged People: %@", self.selectedFriends);
            [self postVideoAndTag];
        }
        else{
            NSLog(@"My Info Error: %@", infoError.localizedDescription);
        }
    }];
}

- (void)postVideoAndTag
{
    NSLog(@"post called");
    
    //VideoUploadAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //[appDelegate reauthorizeSession];

    
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
                                   @"EHRMERGERD A VERDEO", @"title",
                                   @"Cool, cool cool cool", @"description",
                                   nil];
   
    FBRequest *uploadRequest = [FBRequest requestWithGraphPath:@"me/videos"
                                                    parameters:params
                                                    HTTPMethod:@"POST"];
    
    [uploadRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if(!error){
            NSLog(@"Video Done: %@", result);
            
            //Tag Video with Selected Friends; works correctly but commented out while debugging
            for(id userInfo in self.selectedFriends){
                NSString *tagPath = [NSString stringWithFormat:@"%@/tags/%@",[result objectForKey:@"id"],[userInfo objectForKey:@"id"]];
                NSLog(@"Tag path: %@", tagPath);
                FBRequest *tagRequest = [FBRequest requestWithGraphPath: tagPath
                                                             parameters:nil
                                                             HTTPMethod:@"POST"];
                
                [tagRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
                    if(!error){
                        NSLog(@"Tag Done: %@", result);
                    }
                    else{
                        NSLog(@"Tag Error: %@", error.localizedDescription);
                    }
                }];
            }
            //[self postStatusAndTag]
        }
        else{
            NSLog(@"Video Error: %@", error.localizedDescription);
        }
    }];
}

- (void)postStatusAndTag:(id)result
{
    //post comment

     NSMutableDictionary *commentParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"I just posted a video http://ign.com", @"message",
                                           //self.selectedFriends, @"to",
                                           //userID, @"to",
                                           nil];
     
     
     NSString *commentPath = [NSString stringWithFormat:@"%@/comments", [result objectForKey:@"id"]];
     NSLog(@"Comment path: %@", commentPath);
     NSString *comment = @"message = This is a video comment";
     
     FBRequest *commentRequest = [FBRequest requestWithGraphPath:[NSString stringWithFormat:@"%@/%@",commentPath, comment]
     //FBRequest *commentRequest = [FBRequest requestWithGraphPath:@"me/feed"
     //parameters:commentParams
     parameters:nil
     HTTPMethod:@"POST"];
     
     [commentRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
     if(!error){
     NSLog(@"Comment Done: %@", result);
     }
     else{
     NSLog(@"Comment Error: %@", error.localizedDescription);
     }
     }];


}

- (IBAction)buttonClicked:(id)sender
{
    //VideoUploadAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    //[appDelegate openSessionWithAllowLoginUI:NO];
    
    //tag friends
    [self displayFriendPickerController];
    
    //post video and status
    //[self postVideoAndStatusUpdate];
}

- (IBAction)logoutPressed:(id)sender {
    VideoUploadAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (FBSession.activeSession.isOpen) {
        [appDelegate closeSession];
    }
}

#pragma mark - FBFriendPicker Delegate
- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker{
    self.selectedFriends = friendPicker.selection;
    //NSLog(@"Selected friends: %@", self.selectedFriends);
}


@end
