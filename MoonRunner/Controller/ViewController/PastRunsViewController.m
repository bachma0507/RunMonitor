#import "PastRunsViewController.h"
#import "RunDetailsViewController.h"
#import "Run.h"
#import "RunCell.h"
#import "MathController.h"
#import "BadgeController.h"
#import "Badge.h"

@interface PastRunsViewController ()

@property (strong, nonatomic) NSString * stringIntValue;

@end

@implementation PastRunsViewController

#pragma mark - Table View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[myTableView reloadData];
    
    

    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.runArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RunCell *cell = (RunCell *)[tableView dequeueReusableCellWithIdentifier:@"RunCell"];
    Run *runObject = [self.runArray objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    cell.dateLabel.text = [formatter stringFromDate:runObject.timestamp];
    
    cell.distanceLabel.text = [MathController stringifyDistance:runObject.distance.floatValue];
    
    //NSLog(@"runObject distance value is: %f", runObject.distance.floatValue);
    
    
    
    Badge *badge = [[BadgeController defaultController] bestBadgeForDistance:runObject.distance.floatValue];
    cell.badgeImageView.image = [UIImage imageNamed:badge.imageName];
    
    
    return cell;
}

-(int)sum
{
    int sum = 0;
    for(int i = 0; i < self.runArray.count; i++)
    {
        Run *runObject = [self.runArray objectAtIndex:i];
        sum += runObject.distance.integerValue;
    }
    return sum;
    //    NSString * stringIntValue = [MathController stringifyDistance:sum];
    //    NSLog(@"PRINT STRINGINTVALUE = %@", stringIntValue);
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[RunDetailsViewController class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Run *run = [self.runArray objectAtIndex:indexPath.row];
        [(RunDetailsViewController *)[segue destinationViewController] setRun:run];
    }
}

- (IBAction)milesToDateButtonPress:(id)sender {
    
    int total = [self sum];
    
    _stringIntValue = [MathController stringifyDistance:total];
    //NSLog(@"PRINT STRINGINTVALUE = %@", _stringIntValue);
    
    NSString * message = [NSString stringWithFormat:@"Total Miles to Date = %@", _stringIntValue];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Miles to Date"
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
    alertView.tag = 1;
    [alertView show];
}
@end
