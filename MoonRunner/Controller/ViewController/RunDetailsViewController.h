#import <UIKit/UIKit.h>

@class Run;

@interface RunDetailsViewController : UIViewController

@property (strong, nonatomic) Run *run;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
