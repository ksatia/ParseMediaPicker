//
//  AppDelegate.m
//  parseImagePicer
//
//  Created by Aditya Narayan on 8/12/15.
//  Copyright (c) 2015 Aditya Narayan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"fill with your own"
                  clientKey:@"fill with your own"];
    [PFUser enableAutomaticUser];
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    return YES;
}

@end
