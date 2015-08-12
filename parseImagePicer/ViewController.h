//
//  ViewController.h
//  parseImagePicer
//
//  Created by Aditya Narayan on 8/12/15.
//  Copyright (c) 2015 Aditya Narayan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ViewController : UIViewController <UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *imageArray;

@property (weak, nonatomic) IBOutlet UIImageView *image;

- (IBAction)useCamera:(id)sender;

- (IBAction)uploadImage:(id)sender;


@end

