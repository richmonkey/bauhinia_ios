//
//  MessageTests.m
//  MessageTests
//
//  Created by daozhu on 14-6-16.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LevelDB.h"
#import "GroupDB.h"
@interface MessageTests : XCTestCase

@end

@implementation MessageTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLevelDB
{
  LevelDB *db = [LevelDB defaultLevelDB];
  [db setString:@"testv" forKey:@"testk"];
  NSString *v = [db stringForKey:@"testk"];
  XCTAssertTrue([v isEqualToString:@"testv"], @"");
}

-(void)testGroupDB
{
  Group *group = [[Group alloc] init];
  group.groupID = 1;
  group.masterID = 100;
  group.topic = @"test";
  
  
  [[GroupDB instance] addGroup:group];
  
  Group *group2 = [[GroupDB instance] loadGroup:1];
  XCTAssertEqual(group.groupID, group2.groupID, @"");
  
  [[GroupDB instance] removeGroup:1];
}

-(void)testGroupList
{
  Group *group = [[Group alloc] init];
  group.groupID = 1;
  group.masterID = 100;
  group.topic = @"test";
  
  
  [[GroupDB instance] addGroup:group];
  NSArray *groups = [[GroupDB instance] loadAllGroup];
  
  Group *group2 = nil;
  for (Group *g in groups) {
    if (g.groupID == group.groupID) {
      group2 = g;
      break;
      
    }
  }
  XCTAssertTrue(group2, @"");
  XCTAssertEqual(group2.groupID, group.groupID, @"");
  [[GroupDB instance] removeGroup:1];
}

-(void)testGroupMember
{
  Group *group = [[Group alloc] init];
  group.groupID = 1;
  group.masterID = 100;
  group.topic = @"test";
  [group addMember:100];
  
  [[GroupDB instance] addGroup:group];
  Group *group2 = [[GroupDB instance] loadGroup:1];
  XCTAssertEqual([[group2 members] count], [[group members] count], @"");
  BOOL e = [[[group members] objectAtIndex:0] longLongValue] == [[[group2 members] objectAtIndex:0] longLongValue];
  XCTAssertTrue(e, @"");
  [[GroupDB instance] removeGroup:1];
}

@end
