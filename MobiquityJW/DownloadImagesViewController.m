//
//  DownloadImagesViewController.m
//  MobiquityJW
//
//  Created by Justin Wanajrat on 11/11/14.
//  Copyright (c) 2014 Justin Wanajrat. All rights reserved.
//

#import "DownloadImagesViewController.h"

@interface DownloadImagesViewController ()

@end

@implementation DownloadImagesViewController
-(DBRestClient *)restClient
{
    if (!restClient)
    {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = (id)self;
    }
    
    return restClient;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    iv = 0;
    [imagesPathCollectionView registerNib:[UINib nibWithNibName:@"CollectionImageCellCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
    downloadedImagesArray = [[NSMutableArray alloc] init];
   // NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    for (int i =0; i < self.pathsArray.count; i++) {
        NSString *file = [self.pathsArray objectAtIndex:i];
    [self getTotalImages:file];
        
      //  NSInvocationOperation *invoke = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getTotalImages:) object:file];
       // [queue addOperation:invoke];
        
    }
    
    // Do any additional setup after loading the view from its nib.
}
-(IBAction)removeStreachView:(id)sender
{
    [streachView removeFromSuperview];
}
-(void) getTotalImages:(NSString *) file
{
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *fileName = [file stringByReplacingOccurrencesOfString:@"/" withString:@""];
    //    fileName = [file stringByReplacingOccurrencesOfString:@" "  withString:@"%20"];
    NSString *path = [dirPath stringByAppendingPathComponent:fileName];
    if ([path containsString:@".jpeg"] || [path containsString:@".png"] || [path containsString:@".jpg"]) {
        [self startProgress];
        [[self restClient] loadFile:file intoPath:path];
        
    }
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [downloadedImagesArray count];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithRed:90/255.0 green:100/255.0 blue:100/255.0 alpha:1.0]];
    cell.textLabel.textColor = [UIColor cyanColor];
    [tableView setBackgroundColor:[UIColor colorWithRed:90/255.0 green:100/255.0 blue:100/255.0 alpha:1.0]];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //cell.textLabel.text = [downloadedImagesArray objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellAccessoryNone;
    cell.imageView.image = [UIImage imageWithContentsOfFile:[downloadedImagesArray objectAtIndex:indexPath.row]];
    
    // Configure the cell...
    
    return cell;
}
-(IBAction)dismissController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - collectionview delegate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [downloadedImagesArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionImageCellCollectionViewCell *cell = (CollectionImageCellCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];

    cell.cellImage.image = [UIImage imageWithContentsOfFile:[downloadedImagesArray objectAtIndex:indexPath.row]];
    //    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gray-frame.png"]];
    return cell;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    streachView.frame = CGRectMake(25, 60, 270, 490);
    [self.view addSubview:streachView];
    streachImageView.image = [UIImage imageWithContentsOfFile:[downloadedImagesArray objectAtIndex:indexPath.row]];
    
}
#pragma mark - table view Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *file = [self.pathsArray objectAtIndex:indexPath.row];
//    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    
//    NSString *fileName = [[self.pathsArray objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"/" withString:@""];
//    //    fileName = [file stringByReplacingOccurrencesOfString:@" "  withString:@"%20"];
//    NSString *path = [dirPath stringByAppendingPathComponent:fileName];
//    [self startProgress];
//    [[self restClient] loadFile:file intoPath:path];
    
}
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    NSLog(@"File loaded into path: %@", localPath);
    //iv++;
    //if (iv >= self.pathsArray.count) {
        [self stopProgressBar];
   // }
    downloadedImagePath = localPath;
    [downloadedImagesArray addObject:downloadedImagePath];
    //NSString *message = @"file loaded successfully!";
   [imagesPathCollectionView reloadData];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dropbox" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//    [alert show];
}
//-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    ViewDownloadedImageViewController *view = [[ViewDownloadedImageViewController alloc] initWithNibName:@"ViewDownloadedImageViewController" bundle:nil];
//    view.downloadedImagePath = downloadedImagePath;
//    [self presentViewController:view animated:YES completion:nil];
//    
//}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
    NSLog(@"There was an error loading the file - %@", error);
    
    //NSString *message = @"error in loading the file!";
    [self stopProgressBar];
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dropbox" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    //[alert show];
}
-(void)startProgress
{
    if (m_ctrlActivity ==nil)
    {
        m_ctrlActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    m_ctrlActivity.frame = CGRectMake(0.0, self.view.frame.size.height/2, 80.0, 80.0);
    m_ctrlActivity.center = self.view.center;
    [self.view addSubview:m_ctrlActivity];
    m_ctrlActivity.backgroundColor = [UIColor grayColor];
    [m_ctrlActivity layer].opacity = .8;
    [m_ctrlActivity layer].cornerRadius = 8.0;
    // [m_ctrlActivity bringSubviewToFront:self.navigationController.view];
    m_ctrlActivity.hidden = NO;
    [m_ctrlActivity startAnimating];
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [self.view setUserInteractionEnabled:NO];
}
-(void)stopProgressBar
{
    if (m_ctrlActivity != nil)
    {
        [m_ctrlActivity stopAnimating];
        m_ctrlActivity.hidden = YES;
        [self.view setUserInteractionEnabled:YES];
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
