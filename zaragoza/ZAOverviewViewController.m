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
#import "ZAApiService.h"

static NSString *kCellIdentifier = @"StopTableViewCell";

@interface ZAOverviewViewController () <UITableViewDelegate, UITableViewDataSource>

// List of all bus stops
@property (nonatomic, strong) NSArray *busStops;

// Set of ImageDownloader objects for each bus stop map-image
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation ZAOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initalize properties
    self.busStops = [[NSArray alloc]init];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    // Define onSuccess block
    void (^onSuccess)(NSURLSessionTask*, id) = ^(NSURLSessionTask *task, id responseObject) {
        
        // The responseObject should be a NSDictionary, early return if not
        if(![responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Response object is not kind of class `NSDictionary`.");
            return;
        }
        
        // Retrieve locations
        NSArray *locations = [responseObject valueForKey:@"locations"];
        self.busStops = [EKMapper arrayOfObjectsFromExternalRepresentation:locations
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
    
    // Execute GET request
    ZAApiService *apiService = [ZAApiService sharedInstance];
    [apiService requestUrl:@"http://api.dndzgz.com/services/bus"
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.busStops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZAStopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                            forIndexPath:indexPath];
    ZABusStop *busStop = [self.busStops objectAtIndex:indexPath.row];
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
 *   Begin additional data download for a specific index path.
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

- (void)startEstimateDownload:(ZABusStop *)busStop forIndexPath:(NSIndexPath *)indexPath {
    ZAApiService *service = [ZAApiService sharedInstance];
    ZAStopTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [service estimateForBusStopWithId:busStop.identifier
                     withSuccessBlock:^(ZAEstimate *estimate) {
                         busStop.estimate = estimate;
                         // Completion block runs on the main thread --> UI updates are fine
                         [cell.etaLabel setText:[NSString stringWithFormat:@"%ld Minutes", estimate.estimate]];
                     } failureBlock:^(NSString *errorMessage) {
                         NSLog(@"%@", errorMessage);
                         [cell.etaLabel setText:@"An error occured."];
                     }];
}

/*  -------------------------------------------------------------------------------
 *   This method is used in case the user scrolled into a set of cells that don't
 *   have their additional data (image & ETA) yet.
 *  ------------------------------------------------------------------------------- */
- (void)loadDataAdditionsForOnscreenRows {
    if ([self.busStops count] > 0) {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths) {
            ZABusStop *busStop = (self.busStops)[indexPath.row];
            
            // Avoid the image download if the bus stop already has an image
            if (!busStop.image) {
                [self startImageDownload:busStop forIndexPath:indexPath];
            }
            
            // Avoid the estimate download if bus stop already has an estimate
            if (!busStop.estimate) {
                [self startEstimateDownload:busStop forIndexPath:indexPath];
            }
        }
    }
}

/*  -------------------------------------------------------------------------------
 *   Load images for all onscreen rows when scrolling is finished.
 *  ------------------------------------------------------------------------------- */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadDataAdditionsForOnscreenRows];
    }
}

/*  -------------------------------------------------------------------------------
 *   When scrolling stops, proceed to load the app icons that are on screen.
 *  ------------------------------------------------------------------------------- */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadDataAdditionsForOnscreenRows];
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
