//
//  VideoUploadViewController.m
//  FacebookVideoUpload
//
//  Created by Will on 2/12/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import "VideoUploadViewController.h"
#import "VideoUploadAppDelegate.h"

@interface VideoUploadViewController () <FBFriendPickerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) UINavigationController* navController;
@property (nonatomic, strong) NSArray *selectedFriends;  //the items in the array are <FBGraphUser> objects
@property (nonatomic) BOOL sessionIsOpen;
@property (nonatomic, strong) NSDictionary *userFBInfo;
@property (nonatomic) int postCount;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation VideoUploadViewController

@synthesize navController = _navController;
@synthesize selectedFriends = _selectedFriends;
@synthesize sessionIsOpen = _sessionIsOpen;
@synthesize userFBInfo= _userFBInfo;
@synthesize postCount = _postCount;
@synthesize alertView = _alertView;

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

- (UIAlertView *)alertView
{
    if(!_alertView){
        _alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:@"Could not post video to Facebook"
                                                delegate:self
                                       cancelButtonTitle:@"Ok"
                                       otherButtonTitles:@"Try Again", nil];
    }
    return _alertView;
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    if(!_activityIndicatorView){
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.hidesWhenStopped = YES;
    }
    return _activityIndicatorView;
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
    NSLog(@"Display Friend Picker");
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
    NSLog(@"Post video called");
    
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
    
    NSString *currentDate = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   videoData, @"video.mov",
                                   @"video/quicktime", @"contentType",
                                   [NSString stringWithFormat:@"Title de la video (%@)", currentDate], @"title",
                                   [NSString stringWithFormat:@"Decription-o de la video (%@)", currentDate], @"description",
                                   nil];
   
    FBRequest *uploadRequest = [FBRequest requestWithGraphPath:@"me/videos"
                                                    parameters:params
                                                    HTTPMethod:@"POST"];
    
    //display activity indicator view
    [self.activityIndicatorView startAnimating];
    [self.view addSubview:self.activityIndicatorView];
    
    //start video upload
    [uploadRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if(!error){
            NSLog(@"Video Done: %@", result);
            
            //Tag Video with Selected Friends; works correctly but commented out while debugging
            if([self.selectedFriends count] > 0){
                for(id userInfo in self.selectedFriends){
                    NSLog(@"Tagging friends");
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
                            [self.activityIndicatorView stopAnimating];
                            
                            NSLog(@"Tag Error: %@", error.localizedDescription);
                        }
                    }];
                }
            }
            self.postCount = 0;
            //add comment to video
            [self postCommentAndTag:result];
        }
        else{
            //NSLog(@"Video Error: %@", error.localizedDescription);
            NSLog(@"Video Error: %@", error);
            [self.activityIndicatorView stopAnimating];
            [self.alertView show];
            /*
            self.postCount += 1;
            if(self.postCount <= 3){
                [self postVideoAndTag];
            }
            NSLog(@"Post count: %d", self.postCount);
             */
        }
    }];
}

- (void)postCommentAndTag:(id)facebookObject
{
    //post comment
    NSLog(@"Post comment called");
    
    NSMutableDictionary *commentParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"I just posted a video from http://bit.ly/Ve0dzj", @"message",
                                           nil];
     
     NSString *commentPath = [NSString stringWithFormat:@"%@/comments", [facebookObject objectForKey:@"id"]];
     NSLog(@"Comment path: %@", commentPath);
     
     FBRequest *commentRequest = [FBRequest requestWithGraphPath:commentPath
                                                      parameters:commentParams
                                                      HTTPMethod:@"POST"];
     
     [commentRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if(!error){
            NSLog(@"Comment Done: %@", result);
            self.postCount = 0;
            [self.activityIndicatorView stopAnimating];
        }
        else{
            NSLog(@"Comment Error: %@", error.localizedDescription);
            //NSLog(@"Comment Error: %@", error);
            //keep trying to post until succesful
            //have to wait for facebookObject to be available from Facebook
            self.postCount += 1;
            [self postCommentAndTag:facebookObject];
            NSLog(@"Post count: %d", self.postCount);
        }
     }];
}

- (IBAction)buttonClicked:(id)sender
{
    //make sure there is an active and open session
    VideoUploadAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if(![appDelegate sessionIsActiveAndOpen]){
        // if not, call the openSession method and show the login UX if necessary.
        [appDelegate openSessionWithAllowLoginUI:YES];
    }

    [self displayFriendPickerController];
    self.postCount = 0;
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

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self buttonClicked:self];
    }
    
    [self.alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
