//
//  MasterViewController.m
//  Coaster
//
//  Created by naoty on 2013/06/09.
//  Copyright (c) 2013年 Naoto Kaneko. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "Report.h"
#import "Konashi.h"
#import "SVProgressHUD.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [self initializeReports];

    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [Konashi initialize];
    [Konashi addObserver:self selector:@selector(peripheralFound) name:KONASHI_EVENT_PERIPHERAL_FOUND];
    [Konashi addObserver:self selector:@selector(peripheralNotFound) name:KONASHI_EVENT_PERIPHERAL_NOT_FOUND];
    [Konashi addObserver:self selector:@selector(ready) name:KONASHI_EVENT_READY];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeReports
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // フェッチするエンティティを指定する
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Report" inManagedObjectContext:_appDelegate.managedObjectContext];
    [request setEntity:entity];
    
    // ソート順を指定する
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    // フェッチを実行する
    NSError *error = nil;
    _reports = [[_appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (_reports == nil)
        _reports = [NSMutableArray array];
}

- (void)reloadReports
{
    [self initializeReports];
    [self.tableView reloadData];
}

- (void)addButtonTapped
{
    [SVProgressHUD showWithStatus:@"Finding..."];
    [Konashi find];
}

- (void)peripheralFound
{
    [SVProgressHUD dismiss];
}

- (void)peripheralNotFound
{
    [SVProgressHUD showErrorWithStatus:@"Not found"];
}

- (void)ready
{
    [SVProgressHUD showSuccessWithStatus:@"Connected!"];
    [self performSegueWithIdentifier:@"DetailSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![segue.identifier isEqualToString:@"DetailSegue"]) {
        return;
    }
    
    Report *report;
    
    // セルを選択した場合はそのセルのreportを取得する
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        report = _reports[indexPath.row];
    }
    // 新規作成ボタンを押した場合はreportオブジェクトを新規作成する
    else {
        report = (Report *) [NSEntityDescription insertNewObjectForEntityForName:@"Report" inManagedObjectContext:_appDelegate.managedObjectContext];
        report.timestamp = [NSDate date];
    }
    
    DetailViewController *controller = (DetailViewController *) segue.destinationViewController;
    controller.report = report;
    controller.masterViewController = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_reports count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LogCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Report *report = (Report *) _reports[indexPath.row];
    cell.textLabel.text = [_dateFormatter stringFromDate:report.timestamp];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
