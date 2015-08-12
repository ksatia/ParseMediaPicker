//
//  ViewController.m
//  parseImagePicer
//
//  Created by Aditya Narayan on 8/12/15.
//  Copyright (c) 2015 Aditya Narayan. All rights reserved.
//

#import "ViewController.h"
#import "imageObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageArray = [NSMutableArray new];
    [self parseRetrieve];
    }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    imageObject *temp = [self.imageArray objectAtIndex:indexPath.row];
    cell.textLabel.text = temp.key;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.imageArray.count == 0) {
        self.image.image = nil;
    }
    
    else {
    imageObject *object = [self.imageArray objectAtIndex:indexPath.row];
    self.image.image = object.image;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.imageArray.count;
    }




- (IBAction)useCamera:(id)sender {
    UIImagePickerController *iphone = [[UIImagePickerController alloc]init];
    [iphone setDelegate:self];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [iphone setAllowsEditing:YES];
        [iphone setSourceType:UIImagePickerControllerSourceTypeCamera];
    }

}

- (IBAction)uploadImage:(id)sender {
    UIImagePickerController *iphone = [[UIImagePickerController alloc]init];
    [iphone setDelegate:self];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [iphone setAllowsEditing:YES];
        [iphone setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [self presentViewController:iphone animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.image setImage:image];
    
    [self parseUpload:info];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        imageObject *toDelete = [self.imageArray objectAtIndex:indexPath.row];
        [self.imageArray removeObject:toDelete];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        PFQuery *query = [PFQuery queryWithClassName:@"Images"];
        [query whereKey:@"key" equalTo:toDelete.key];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (!error) {
                [[objects objectAtIndex:0]deleteInBackground];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.imageArray.count == 0) {
                    [self.image setImage:nil];
                    [self.tableView reloadData];
                }
        });
        }];
}
}

-(void)parseRetrieve {
    PFQuery *query = [PFQuery queryWithClassName:@"Images"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject * temp in objects){
                imageObject *new = [imageObject new];
                new.key = [temp objectForKey:@"key"];
          
        
                PFFile *tempFile = [temp objectForKey:@"image"];
                [tempFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        UIImage *downloadedImage = [UIImage imageWithData:imageData];
                        new.image = downloadedImage;
                        [self.imageArray addObject:new];
                    }
                    NSLog(@"Downloaded....%@  %@", new.key, new.image.description);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }];
            }}
        
        else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}



-(void)parseUpload:(NSDictionary *)dictionary {
    
    UIImage *image = [dictionary objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *file = [PFFile fileWithName:@"image" data:imageData];
    
    PFObject *imageFile = [PFObject objectWithClassName:@"Images"];

    NSString *key = [[NSString alloc] initWithFormat:@"%f.jpg", [[NSDate date] timeIntervalSince1970 ]];
    
    imageFile[@"key"] = key;
    imageFile[@"image"] = file;
    
    imageObject *temp = [imageObject new];
    temp.key = key;
    temp.image = image;
    [self.imageArray addObject:temp];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
     if (succeeded) {
         NSLog(@"saved");
        }
    }];
}

@end


