/*
 //   LSSimpleKeychainWrapper.m
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
#import "LSSimpleKeyChainWrapper.h"

@interface LSSimpleKeyChainWrapper()
@property (nonatomic,strong)NSString* service;
@property (nonatomic,strong)NSString* account;
@end

@implementation LSSimpleKeyChainWrapper
+(id)keyChainWrapperForService:(NSString*)service andAccount:(NSString*)account
{
    static LSSimpleKeyChainWrapper* wrapper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wrapper = [[LSSimpleKeyChainWrapper alloc]init];
        if (wrapper)
        {
            [wrapper initializeWithService:service andAccount:account];
        }
    });
    return wrapper;
}

-(void)initializeWithService:(NSString*)service andAccount:(NSString*)account
{
    _service = service;
    _account = account;
}


-(OSStatus)saveData:(id)data
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery];
    
    // Add data to be saved
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    // Try to save
    OSStatus result = SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
    // Check if data already exists
    if (result == errSecDuplicateItem)
	{
        NSMutableDictionary* attrToUpdate = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSKeyedArchiver archivedDataWithRootObject:data] ,(__bridge id)kSecValueData,nil];
        // If so, update
        result = SecItemUpdate((__bridge CFDictionaryRef)[self getKeychainQuery], (__bridge CFDictionaryRef)(attrToUpdate));
    }
    
    return result;
}

-(id)fetchData
{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", self.service, e);
            if (keyData) CFRelease(keyData);
            @throw ;
            
        }
    }
    if (keyData) CFRelease(keyData);
    return ret;
    
}

-(OSStatus)deleteData
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery];
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    return result;
}

#pragma mark - utils 
-(NSMutableDictionary *)getKeychainQuery{
    // Update the kSecAttrAccessible value depending on security needs for your application. The default behavior allows access to keychain value even when locked and allows this to be backed up
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            self.service, (__bridge id)kSecAttrService,
            self.account, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible,
            nil];
}


@end
