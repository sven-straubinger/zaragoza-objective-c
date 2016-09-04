//
//  ZAOverviewViewController.m
//  zaragoza
//
//  Created by Sven Straubinger on 01/09/16.
//  Copyright © 2016 Sven Straubinger. All rights reserved.
//

#import "ZAOverviewViewController.h"
#import "ZABusStop.h"
#import "ZAStopTableViewCell.h"
#import "ImageDownloader.h"
#import "UIAlertController+Collections.h"

static NSString *kCellIdentifier = @"StopTableViewCell";

@interface ZAOverviewViewController () <UITableViewDelegate, UITableViewDataSource>

// List of all bus stops
@property (nonatomic, strong) NSArray *stops;

// Set of ImageDownloader objects for each bus stop map-image
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation ZAOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initalize properties
    self.stops = [[NSArray alloc]init];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    // Define onSuccess block
    void (^onSuccess)(NSURLSessionTask*, id) = ^(NSURLSessionTask *task, id responseObject) {
        
        /* The responseObject should be a NSDictionary, early return if not */
        if(![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Response object is not kind of class `NSDictionary`.");
            return;
        }
        
        // Retrieve locations
        NSArray *locations = [responseObject valueForKey:@"locations"];
        self.stops = [EKMapper arrayOfObjectsFromExternalRepresentation:locations
                                                            withMapping:[ZABusStop objectMapping]];
        // Reload table view
        [self.tableView reloadData];

    };
    
    // Define onFailure block - display alert
    void (^onFailure)(NSURLSessionTask*, NSError*) = ^(NSURLSessionTask* task, NSError *error) {
        UIAlertController *alert = [UIAlertController controllerWithTitle:@"An error occured"
                                                                  message:error.localizedDescription
                                                              actionTitle:@"Ok"];
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    // Execute HTTP GET request
    [self requestUrl:@"http://api.dndzgz.com/services/bus"
    withSuccessBlock:onSuccess
        failureBlock:onFailure];
}


#pragma mark - Lifecyclye

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self terminateAllDownloads];
}

- (void)dealloc {
    [self terminateAllDownloads];
}


#pragma mark - AFNetworking

- (void)requestUrl:(NSString *)url
  withSuccessBlock:(void (^)(NSURLSessionTask *task, id responseObject))onSuccess
      failureBlock:(void (^)(NSURLSessionTask *task, NSError *error))onFailure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url
      parameters:nil
        progress:nil
         success:onSuccess
         failure:onFailure];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.stops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZAStopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                            forIndexPath:indexPath];
    ZABusStop *busStop = [self.stops objectAtIndex:indexPath.row];
    cell.identifierLabel.text = busStop.identifier;
    cell.nameLabel.text = busStop.name;
    cell.etaLabel.text = @"Loading ...";
    
    // Only display cached images, defer new downloads until scrolling ends
    if (!busStop.image) {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
            [self startImageDownload:busStop forIndexPath:indexPath];
        }
        // If a download is deferred or in progress, return a placeholder image
        cell.mapImageView.image = [UIImage imageNamed:@"placeholder.png"];
    } else {
        cell.mapImageView.image = busStop.image;
    }
    
    return cell;
}


#pragma mark - Image support & UIScrollViewDelegate methods

/*  -------------------------------------------------------------------------------
 *   This section implements the samples from:
 *   https://developer.apple.com/library/ios/samplecode/LazyTableImages/Introduction/Intro.html
 *  ------------------------------------------------------------------------------- */

/*  -------------------------------------------------------------------------------
 *   Begin an image download for a specific index path.
 *  ------------------------------------------------------------------------------- */
- (void)startImageDownload:(ZABusStop *)busStop forIndexPath:(NSIndexPath *)indexPath {
    ImageDownloader *imageDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (imageDownloader == nil) {
        imageDownloader = [[ImageDownloader alloc] init];
        imageDownloader.busStop = busStop;
        [imageDownloader setCompletionHandler:^{
            
            ZAStopTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.mapImageView.image = busStop.image;
            
            // Remove the ImageDownloade from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = imageDownloader;
        [imageDownloader startDownload];
    }
}

/*  -------------------------------------------------------------------------------
 *   This method is used in case the user scrolled into a set of cells that don't
 *   have their image yet.
 *  ------------------------------------------------------------------------------- */
- (void)loadImagesForOnscreenRows {
    if (self.stops.count > 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            ZABusStop *busStop = (self.stops)[indexPath.row];
            
            // Avoid the app icon download if the app already has an icon
            if (!busStop.image) {
                [self startImageDownload:busStop forIndexPath:indexPath];
            }
        }
    }
}

/*  -------------------------------------------------------------------------------
 *   Load images for all onscreen rows when scrolling is finished.
 *  ------------------------------------------------------------------------------- */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnscreenRows];
    }
}

/*  -------------------------------------------------------------------------------
 *   When scrolling stops, proceed to load the app icons that are on screen.
 *  ------------------------------------------------------------------------------- */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenRows];
}

/*  -------------------------------------------------------------------------------
 *   Terminate all pending downloads.
 *  ------------------------------------------------------------------------------- */
- (void)terminateAllDownloads {
    // Terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

@end
