/*
 //  LSSimpleKeychainWrapperDataDeleteTests.m
 //   LSSimpleKeychainWrapper
 //
 //  Created by Priya Rajagopal
 //  Copyright (c) 2014 Lunaria Software, LLC. All rights reserved.
 //
 // Permission is hereby granted, free of charge, to any person obtaining a copy
 // of this software and associated documentation files (the "Software"), to deal
 // in the Software without restriction, including without limitation the rights
 // to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 // copies of the Software, and to permit persons to whom the Software is
 // furnished to do so, subject to the following conditions:
 //
 // The above copyright notice and this permission notice shall be included in
 // all copies or substantial portions of the Software.
 //
 // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 // IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 // FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 // AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 // LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 // OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 // THE SOFTWARE.
 */
#import <XCTest/XCTest.h>
#import "LSSimpleKeyChainWrapper.h"

@interface LSSimpleKeychainWrapperDataDeleteTests : XCTestCase
@property (nonatomic,strong)LSSimpleKeyChainWrapper* kcWrapper;
@property (nonatomic,strong)NSDictionary* dataToSave;

@end

@implementation LSSimpleKeychainWrapperDataDeleteTests
- (void)setUp
{
    [super setUp];
    NSString* fakePassword = @"Password";
    self.kcWrapper = [self singletonWrapper];
    self.dataToSave = @{@"email":@"user@example.com",@"password":@"dummy"};

    OSStatus result = [self.kcWrapper saveData:self.dataToSave];
    XCTAssertEqual(result,0);
}

- (void)tearDown
{
     [super tearDown];
}


-(void)testDataDelete {
    OSStatus result = [self.kcWrapper deleteData];
    XCTAssertEqual(result,0);
}

-(void)testDataLoadAfterDelete {
    [self testDataDelete];
    NSString* data = [self.kcWrapper fetchData];
    XCTAssertNil(data);
   // XCTAssertThrowsSpecific([self.kcWrapper fetchData], NSException);
}


#pragma mark - helper
-(LSSimpleKeyChainWrapper*)singletonWrapper {
    return [LSSimpleKeyChainWrapper keyChainWrapperForService:@"myService" andAccount:@"myAccount"];
}
@end
