#import "PastRunsViewController.h"
#import "RunDetailsViewController.h"
#import "Run.h"
#import "RunCell.h"
#import "MathController.h"
#import "BadgeController.h"
#import "Badge.h"

@interface PastRunsViewController ()


@end

@implementation PastRunsViewController

#pragma mark - Table View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[myTableView reloadData];
    
    int total = [self sum];
    
    NSString * stringIntValue = [MathController stringifyDistance:total];
    NSLog(@"PRINT STRINGINTVALUE = %@", stringIntValue);
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
    //NSLog(@"RUNARRAY COUNT = %lu", (unsigned long)self. runArray.count);
    
//    float total = 0.0;
//    for (int i = 0; i <= self.runArray.count; i++) {
//        
//        //total += runObject.distance.floatValue;
//        total += runObject.distance.floatValue;
//        //NSLog(@"PRINT FLOAT TOTAL = %f", total);
//        
//    };
//    
//    NSString * stringValue = [MathController stringifyDistance:total];
//    NSLog(@"PRINT STRING TOTAL = %@", stringValue);
    
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

@end
