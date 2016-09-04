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

static NSString *kCellIdentifier = @"StopTableViewCell";

@interface ZAOverviewViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *stops;

@end

@implementation ZAOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stops = [[NSArray alloc]init];
    
    // Define onSuccess block
    void (^onSuccess)(NSURLSessionTask*, id) = ^(NSURLSessionTask *task, id responseObject) {
        
        /*
         {} JSON
           {} lines
           [] locations
             {} 0
               "id"
               "title"
             {} 1
             ...
         */
        
        /* responseObject should be a NSDictionary, early return if not */
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
    
    // Define onFailure block
    void (^onFailure)(NSURLSessionTask*, NSError*) = ^(NSURLSessionTask* task, NSError *error) {
        // Display alert
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"An error occured"
                                    message:error.localizedDescription
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"Ok"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    // Execute HTTP GET request
    [self requestUrl:@"http://api.dndzgz.com/services/bus"
    withSuccessBlock:onSuccess
        failureBlock:onFailure];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - AFNetworking
#warning Move implementation to own service
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
    ZABusStop *stop = [self.stops objectAtIndex:indexPath.row];
    cell.identifierLabel.text = stop.identifier;
    cell.nameLabel.text = stop.name;
    cell.etaLabel.text = stop.eta;
    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
