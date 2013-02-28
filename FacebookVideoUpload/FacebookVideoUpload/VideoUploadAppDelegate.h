//
//  VideoUploadAppDelegate.h
//  FacebookVideoUpload
//
//  Created by Will on 2/12/13.
//  Copyright (c) 2013 Will. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoUploadViewController;

@interface VideoUploadAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) VideoUploadViewController *viewController;

extern NSString *const FBSessionStateChangedNotification;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;
- (void)reauthorizeSession;

@end

//changed