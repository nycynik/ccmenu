
#import "CCMBuildNotificationFactory.h"
#import "CCMProject.h"
#import "CCMProjectStatus.h"


NSString *CCMBuildStartNotification = @"CCMBuildStartNotification";
NSString *CCMBuildCompleteNotification = @"CCMBuildCompleteNotification";

NSString *CCMSuccessfulBuild = @"Successful";
NSString *CCMFixedBuild = @"Fixed";
NSString *CCMBrokenBuild = @"Broken";
NSString *CCMStillFailingBuild = @"Still failing";


@implementation CCMBuildNotificationFactory

- (NSString *)buildResultForLastStatus:(NSString *)lastStatus newStatus:(NSString *)newStatus
{
	if([lastStatus isEqualToString:CCMSuccessStatus] && [newStatus isEqualToString:CCMSuccessStatus])
		return CCMSuccessfulBuild;
	if([lastStatus isEqualToString:CCMSuccessStatus] && [newStatus isEqualToString:CCMFailedStatus])
		return CCMBrokenBuild;
	if([lastStatus isEqualToString:CCMFailedStatus] && [newStatus isEqualToString:CCMSuccessStatus])
		return CCMFixedBuild;
	if([lastStatus isEqualToString:CCMFailedStatus] && [newStatus isEqualToString:CCMFailedStatus])
		return CCMStillFailingBuild;
	return @"";
}

- (NSDictionary *)completeInfoForProject:(CCMProject *)project withOldStatus:(CCMProjectStatus *)oldStatus
{
	NSMutableDictionary *notificationInfo = [NSMutableDictionary dictionary];
	[notificationInfo setObject:oldStatus forKey:@"oldStatus"];
	NSString *result = [self buildResultForLastStatus:[oldStatus lastBuildStatus] newStatus:[[project status] lastBuildStatus]];
	[notificationInfo setObject:result forKey:@"buildResult"];
	return notificationInfo;
}

- (NSDictionary *)startInfoForProject:(CCMProject *)project withOldStatus:(CCMProjectStatus *)oldStatus
{
	NSMutableDictionary *notificationInfo = [NSMutableDictionary dictionary];
	[notificationInfo setObject:oldStatus forKey:@"oldStatus"];
	return notificationInfo;
}

- (NSNotification *)notificationForProject:(CCMProject *)project withOldStatus:(CCMProjectStatus *)oldStatus
{
	if([[oldStatus activity] isEqualToString:CCMSleepingActivity] &&
	   [[[project status] activity] isEqualToString:CCMBuildingActivity])
    {
		NSDictionary *buildStartInfo = [self startInfoForProject:project withOldStatus:oldStatus];
		return [NSNotification notificationWithName:CCMBuildStartNotification object:project userInfo:buildStartInfo];
    }
	if([[oldStatus activity] isEqualToString:CCMBuildingActivity] &&
	   ![[[project status] activity] isEqualToString:CCMBuildingActivity])
	{
		NSDictionary *buildCompleteInfo = [self completeInfoForProject:project withOldStatus:oldStatus];
		return [NSNotification notificationWithName:CCMBuildCompleteNotification object:project userInfo:buildCompleteInfo];
	} 
	if(([oldStatus lastBuildStatus] != nil) &&
       ![[oldStatus lastBuildStatus] isEqualToString:[[project status] lastBuildStatus]])
	{
		NSDictionary *buildCompleteInfo = [self completeInfoForProject:project withOldStatus:oldStatus];
		return [NSNotification notificationWithName:CCMBuildCompleteNotification object:project userInfo:buildCompleteInfo];
	}
	return nil;
}

@end
