/*
 ==============================================================================
 CEKeyBindingManager
 
 CotEditor
 http://coteditor.com
 
 Created on 2005-09-01 by nakamuxu
 encoding="UTF-8"
 ------------------------------------------------------------------------------
 
 © 2004-2007 nakamuxu
 © 2014 CotEditor Project
 
 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.
 
 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with
 this program; if not, write to the Free Software Foundation, Inc., 59 Temple
 Place - Suite 330, Boston, MA  02111-1307, USA.
 
 ==============================================================================
 */

#import "CEKeyBindingManager.h"
#import "CEAppDelegate.h"
#import "CEUtils.h"
#import "constants.h"


// outlineView data key, column identifier
NSString *const CEKeyBindingTitleKey = @"title";
NSString *const CEKeyBindingChildrenKey = @"children";
NSString *const CEKeyBindingKeySpecCharsKey = @"keyBindingKey";
NSString *const CEKeyBindingSelectorStringKey = @"selectorString";


@interface CEKeyBindingManager ()

@property (nonatomic, copy) NSDictionary *defaultMenuKeyBindingDict;
@property (nonatomic, copy) NSDictionary *menuKeyBindingDict;
@property (nonatomic, copy) NSDictionary *textKeyBindingDict;

@end




#pragma mark -

@implementation CEKeyBindingManager

static NSDictionary *kUnprintableKeyTable;


#pragma mark Class Methods

//=======================================================
// Class method
//
//=======================================================

// ------------------------------------------------------
/// initialize
+ (void)initialize
// ------------------------------------------------------
{
    // set statics
    kUnprintableKeyTable = [CEKeyBindingManager unprintableKeyDictionary];
}


// ------------------------------------------------------
/// return singleton instance
+ (instancetype)sharedManager
// ------------------------------------------------------
{
    static dispatch_once_t predicate;
    static id shared = nil;
    
    dispatch_once(&predicate, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}


//------------------------------------------------------
/// キーバインディング定義文字列から表示用文字列を生成し、返す
+ (NSString *)printableKeyStringFromKeySpecChars:(NSString *)string
//------------------------------------------------------
{
    NSInteger length = [string length];
    
    if (length < 2) { return @""; }
    
    NSString *keyEquivalent = [string substringFromIndex:(length - 1)];
    NSString *keyStr = [CEKeyBindingManager printableKeyStringsFromKeyEquivalent:keyEquivalent];
    BOOL drawsShift = (isupper([keyEquivalent characterAtIndex:0]) == 1);
    NSString *modKeyStr = [CEKeyBindingManager printableKeyStringFromModKeySpecChars:[string substringToIndex:(length - 1)]
                                                                        withShiftKey:drawsShift];
    
    return [NSString stringWithFormat:@"%@%@", modKeyStr, keyStr];
}


//------------------------------------------------------
/// メニューのキーボードショートカットからキーバインディング定義文字列を返す
+ (NSString *)keySpecCharsFromKeyEquivalent:(NSString *)string modifierFrags:(NSUInteger)modifierFlags
//------------------------------------------------------
{
    if ([string length] < 1) { return @""; }
    
    NSMutableString *keySpecChars = [NSMutableString string];
    unichar theChar = [string characterAtIndex:0];
    BOOL isShiftPressed = NO;
    
    for (NSInteger i = 0; i < kSizeOfModifierKeys; i++) {
        if ((modifierFlags & kModifierKeyMaskList[i]) || ((i == CEShiftKeyIndex) && (isupper(theChar) == 1))) {
            // （メニューから定義値を取得した時、アルファベット+シフトの場合にシフトの定義が欠落するための回避処置）
            [keySpecChars appendFormat:@"%C", kKeySpecCharList[i]];
            if ((i == CEShiftKeyIndex) && (isupper(theChar) == 1)) {
                isShiftPressed = YES;
            }
        }
    }
    [keySpecChars appendString:(isShiftPressed ? [string uppercaseString] : string)];
    
    return keySpecChars;
}



#pragma mark Public Methods

//=======================================================
// Public method
//
//=======================================================

// ------------------------------------------------------
/// 起動時の準備
- (void)setupAtLaunching
// ------------------------------------------------------
{
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"MenuKeyBindings"
                                         withExtension:@"plist"
                                          subdirectory:@"KeyBindings"];

    if ([URL checkResourceIsReachableAndReturnError:nil]) {
        [self setDefaultMenuKeyBindingDict:[NSDictionary dictionaryWithContentsOfURL:URL]];
    }
    /// 定義ファイルのセットアップと読み込み
    [self setupMenuKeyBindingDictionary];
    [self setupTextKeyBindingDictionary];
    
    [self resetAllMenuKeyBindingWithDictionary];
}


// ------------------------------------------------------
/// キー入力に応じたセレクタ文字列を返す
- (NSString *)selectorStringWithKeyEquivalent:(NSString *)string modifierFrags:(NSUInteger)modifierFlags
// ------------------------------------------------------
{
    NSString *keySpecChars = [CEKeyBindingManager keySpecCharsFromKeyEquivalent:string modifierFrags:modifierFlags];

    return [self textKeyBindingDict][keySpecChars];
}


// ------------------------------------------------------
/// メニューキーバインディングがカスタマイズされているか
- (BOOL)usesDefaultMenuKeyBindings
// ------------------------------------------------------
{
    return ![[self menuKeyBindingSettingFileURL] checkResourceIsReachableAndReturnError:nil];
}


//------------------------------------------------------
/// テキストキーバインディングの現在の保持データから設定を読み込み編集用アウトラインビューデータ配列を返す
- (NSMutableArray *)textKeySpecCharArrayForOutlineDataWithFactoryDefaults:(BOOL)usesFactoryDefaults
//------------------------------------------------------
{
    // usesFactoryDefaults == YES で標準設定を返す。NO なら現在の設定を返す。
    
    NSMutableArray *textKeySpecCharArray = [NSMutableArray array];
    
    for (NSString *selector in [CEKeyBindingManager textKeyBindingSelectorStrArray]) {
        if ([selector length] == 0) { continue; }
        
        NSArray *keys;
        if (usesFactoryDefaults) {
            NSURL *sourceURL = [[NSBundle mainBundle] URLForResource:@"TextKeyBindings" withExtension:@"plist"];
            NSDictionary *defaultDict = [NSDictionary dictionaryWithContentsOfURL:sourceURL];
            keys = [defaultDict allKeysForObject:selector];
        } else {
            keys = [[self textKeyBindingDict] allKeysForObject:selector];
        }
        NSString *key = ([keys count] > 0) ? keys[0] : @"";
        
        [textKeySpecCharArray addObject:[@{CEKeyBindingTitleKey: selector,
                                           CEKeyBindingKeySpecCharsKey: key,
                                           CEKeyBindingSelectorStringKey: selector} mutableCopy]];
    }
    return textKeySpecCharArray;
}


//------------------------------------------------------
/// 現在のメニューからショートカットキー設定を読み込み編集用アウトラインビューデータ配列を返す
- (NSMutableArray *)mainMenuArrayForOutlineData:(NSMenu *)menu
//------------------------------------------------------
{
    NSMutableArray *outlineDataArray = [NSMutableArray array];
    
    for (NSMenuItem *item in [menu itemArray]) {
        if ([item isSeparatorItem] || ([[item title] length] == 0)) { continue; }
        
        BOOL hasSpecialTag = (([item tag] == CEServicesMenuItemTag) ||
                              ([item tag] == CEWindowPanelsMenuItemTag) ||
                              ([item tag] == CEScriptMenuDirectoryTag));
        
        NSDictionary *row;
        if ([item hasSubmenu] && !hasSpecialTag) {
            NSMutableArray *subArray = [self mainMenuArrayForOutlineData:[item submenu]];
            row = @{CEKeyBindingTitleKey: [item title],
                    CEKeyBindingChildrenKey: subArray};
            
        } else {
            NSString *selectorString = NSStringFromSelector([item action]);
            
            // フォントサイズ変更、エンコーディングの各項目、カラーリングの各項目、などはリストアップしない
            if ([[CEKeyBindingManager selectorStringsToIgnore] containsObject:selectorString] || hasSpecialTag) {
                continue;
            }
            if ([item isAlternate]) {
                continue;
            }
            
            NSString *keyEquivalent = [item keyEquivalent];
            NSString *keySpecChars;
            if ([keyEquivalent length] > 0) {
                NSUInteger modifierMask = [item keyEquivalentModifierMask];
                keySpecChars = [CEKeyBindingManager keySpecCharsFromKeyEquivalent:keyEquivalent
                                                                    modifierFrags:modifierMask];
            } else {
                keySpecChars = @"";
            }
            row = @{CEKeyBindingTitleKey: [item title],
                    CEKeyBindingKeySpecCharsKey: keySpecChars,
                    CEKeyBindingSelectorStringKey: selectorString};
        }
        [outlineDataArray addObject:[row mutableCopy]];
    }
    return outlineDataArray;
}


//------------------------------------------------------
/// デフォルト設定の、セレクタ名を定義しているキーバインディング文字列（キー）を得る
- (NSString *)keySpecCharsInDefaultDictionaryFromSelectorString:(NSString *)selectorString
//------------------------------------------------------
{
    NSArray *keys = [[self defaultMenuKeyBindingDict] allKeysForObject:selectorString];
    
    return ([keys count] > 0) ? (NSString *)keys[0] : @"";
}


//------------------------------------------------------
/// メニューキーバインディング設定を保存
- (BOOL)saveMenuKeyBindings:(NSArray *)outlineViewData
//------------------------------------------------------
{
    NSDictionary *dictToSave = [self keyBindingDictionaryFromOutlineViewDataArray:outlineViewData];
    NSURL *fileURL = [self menuKeyBindingSettingFileURL];
    BOOL success = NO;
    
    // デフォルトと同じ場合は現在のユーザ設定ファイルを削除する
    if ([dictToSave isEqualToDictionary:[self defaultMenuKeyBindingDict]]) {
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        success = YES;
        
    } else {
        if ([self prepareUserSettingDicrectory]) {
            success = [dictToSave writeToURL:fileURL atomically:YES];
        }
    }
    
    // メニューに反映させる
    if (success) {
        [self setMenuKeyBindingDict:dictToSave];
    } else {
        NSLog(@"Error on saving the menu keybindings setting file.");
    }
    [self resetAllMenuKeyBindingWithDictionary];
    
    return success;
}


//------------------------------------------------------
/// テキストキーバインディング設定を保存
- (BOOL)saveTextKeyBindings:(NSArray *)outlineViewData texts:(NSArray *)texts
//------------------------------------------------------
{
    NSDictionary *dictToSave = [self keyBindingDictionaryFromOutlineViewDataArray:outlineViewData];
    NSURL *fileURL = [self textKeyBindingSettingFileURL];
    
    if ([self prepareUserSettingDicrectory]) {
        [self setTextKeyBindingDict:dictToSave];
        
        if (![dictToSave writeToURL:fileURL atomically:YES]) {
            NSLog(@"Error! Could not save the Text keyBindings setting file...");
            return NO;
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![texts isEqualToArray:[defaults arrayForKey:CEDefaultInsertCustomTextArrayKey]]) {
        NSMutableArray *defaultsArray = [NSMutableArray array];
        
        for (NSDictionary *dict in texts) {
             NSString *insertText = dict[CEDefaultInsertCustomTextKey] ? : @"";
            [defaultsArray addObject:insertText];
        }
        [defaults setObject:defaultsArray forKey:CEDefaultInsertCustomTextArrayKey];
    }
    
    return YES;
}



#pragma mark Private Mthods

//=======================================================
// Private method
//
//=======================================================

//------------------------------------------------------
/// キーバインディング設定ファイル保存用ディレクトリのURLを返す
- (NSURL *)userSettingDirecotryURL
//------------------------------------------------------
{
    return [[(CEAppDelegate *)[NSApp delegate] supportDirectoryURL] URLByAppendingPathComponent:@"KeyBindings"];
}


//------------------------------------------------------
/// メニューキーバインディング設定ファイル保存用ファイルのURLを返す
- (NSURL *)menuKeyBindingSettingFileURL
//------------------------------------------------------
{
    return [[[self userSettingDirecotryURL] URLByAppendingPathComponent:@"MenuKeyBindings"]
                                            URLByAppendingPathExtension:@"plist"];
}


//------------------------------------------------------
/// メニューキーバインディング設定ファイル保存用ファイルのURLを返す
- (NSURL *)textKeyBindingSettingFileURL
//------------------------------------------------------
{
    return [[[self userSettingDirecotryURL] URLByAppendingPathComponent:@"TextKeyBindings"]
                                            URLByAppendingPathExtension:@"plist"];
}


//------------------------------------------------------
/// ユーザ設定ディレクトリがない場合は作成する
- (BOOL)prepareUserSettingDicrectory
//------------------------------------------------------
{
    BOOL success = NO;
    NSError *error = nil;
    NSURL *URL = [self userSettingDirecotryURL];
    NSNumber *isDirectory;
    
    if (![URL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil]) {
        success = [[NSFileManager defaultManager] createDirectoryAtURL:URL
                                           withIntermediateDirectories:YES attributes:nil error:&error];
    } else {
        success = [isDirectory boolValue];
    }
    
    if (!success) {
        NSLog(@"failed to create a directory at \"%@\".", URL);
    }
    
    return success;
}


// ------------------------------------------------------
/// メニューキーバインディング定義ファイルのセットアップと読み込み
- (void)setupMenuKeyBindingDictionary
// ------------------------------------------------------
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:[self menuKeyBindingSettingFileURL]] ?
                       : [self defaultMenuKeyBindingDict];
    
    [self setMenuKeyBindingDict:dict];
}


// ------------------------------------------------------
/// テキストキーバインディング定義ファイルのセットアップと読み込み
- (void)setupTextKeyBindingDictionary
// ------------------------------------------------------
{
    NSURL *fileURL = [self textKeyBindingSettingFileURL];
    
    if ([self prepareUserSettingDicrectory]) {
        NSURL *sourceURL = [[NSBundle mainBundle] URLForResource:@"TextKeyBindings"
                                                   withExtension:@"plist"
                                                    subdirectory:@"KeyBindings"];
        
        if ([sourceURL checkResourceIsReachableAndReturnError:nil] &&
            ![fileURL checkResourceIsReachableAndReturnError:nil])
        {
            if (![[NSFileManager defaultManager] copyItemAtURL:sourceURL toURL:fileURL error:nil]) {
                NSLog(@"Error! Could not copy \"%@\" to \"%@\"...", sourceURL, fileURL);
                return;
            }
        }
        
        // データ読み込み
        [self setTextKeyBindingDict:[NSDictionary dictionaryWithContentsOfURL:fileURL]];
    }
}


//------------------------------------------------------
/// すべてのメニューのキーボードショートカットをクリアする
- (void)clearAllMenuKeyBindingOf:(NSMenu *)menu
//------------------------------------------------------
{
    for (NSMenuItem *item in [menu itemArray]) {
        // フォントサイズ変更、エンコーディングの各項目、カラーリングの各項目、などは変更しない
        if ([[CEKeyBindingManager selectorStringsToIgnore] containsObject:NSStringFromSelector([item action])] ||
            ([item tag] == CEServicesMenuItemTag) ||
            ([item tag] == CEWindowPanelsMenuItemTag) ||
            ([item tag] == CEScriptMenuDirectoryTag))
        {
            continue;
        }
        if ([item isAlternate]) {  // 隠しメニューは変更しない
            continue;
        }
        [item setKeyEquivalent:@""];
        [item setKeyEquivalentModifierMask:0];
        if ([item hasSubmenu]) {
            [self clearAllMenuKeyBindingOf:[item submenu]];
        }
    }
}


//------------------------------------------------------
/// キーボードショートカット設定を反映させる
- (void)updateMenuValidation:(NSMenu *)menu
//------------------------------------------------------
{
    [menu update];
    
    for (NSMenuItem *item in [menu itemArray]) {
        if ([item hasSubmenu]) {
            [self updateMenuValidation:[item submenu]];
        }
    }
}


//------------------------------------------------------
/// すべてのメニューにキーボードショートカットを設定し直す
- (void)resetAllMenuKeyBindingWithDictionary
//------------------------------------------------------
{
    if (![self menuKeyBindingDict]) { return; }

    // まず、全メニューのショートカット定義をクリアする
    [self clearAllMenuKeyBindingOf:[NSApp mainMenu]];

    [self resetKeyBindingWithDictionaryTo:[NSApp mainMenu]];
    // メニュー更新（キーボードショートカット設定反映）
    [self updateMenuValidation:[NSApp mainMenu]];
}


//------------------------------------------------------
/// メニューにキーボードショートカットを設定する
- (void)resetKeyBindingWithDictionaryTo:(NSMenu *)menu
//------------------------------------------------------
{
    BOOL isJapaneseResource = [[[NSBundle mainBundle] preferredLocalizations][0] isEqualToString:@"ja"];
    NSString *yen = [NSString stringWithCharacters:&kYenMark length:1];
    
    // NSMenu の indexOfItemWithTarget:andAction: だと取得できないメニューアイテムがあるため、メニューをひとつずつなめる
    for (NSMenuItem *item in [menu itemArray]) {
        NSString *selectorString = NSStringFromSelector([item action]);
        
        // フォントサイズ変更、エンコーディングの各項目、カラーリングの各項目、などは変更しない
        if ([[CEKeyBindingManager selectorStringsToIgnore] containsObject:selectorString] ||
            ([item tag] == CEServicesMenuItemTag) ||
            ([item tag] == CEWindowPanelsMenuItemTag) ||
            ([item tag] == CEScriptMenuDirectoryTag))
        {
            continue;
        }
        
        if ([item hasSubmenu]) {
            [self resetKeyBindingWithDictionaryTo:[item submenu]];
            
        } else {
            NSString *keySpecChars = [self keySpecCharsInDictionaryFromSelectorString:selectorString];
            NSUInteger modifierMask = 0;
            NSString *keyEquivalent = [CEUtils keyEquivalentAndModifierMask:&modifierMask
                                                                 fromString:keySpecChars
                                                        includingCommandKey:YES];

            // keySpecChars があり Cmd が設定されている場合だけ、反映させる
            if (([keySpecChars length] > 0) && (modifierMask & NSCommandKeyMask)) {
                // 日本語リソースが使われたとき、Input BackSlash の keyEquivalent を変更する
                // （半角円マークのままだと半角カナ「エ」に化けるため）
                if (isJapaneseResource && [keyEquivalent isEqualToString:yen]) {
                    [item setKeyEquivalent:@"\\"];
                } else {
                    [item setKeyEquivalent:keyEquivalent];
                }
                [item setKeyEquivalentModifierMask:modifierMask];
            }
        }
    }
}


//------------------------------------------------------
/// アウトラインビューデータから保存用辞書を生成
- (NSMutableDictionary *)keyBindingDictionaryFromOutlineViewDataArray:(NSArray *)array
//------------------------------------------------------
{
    NSMutableDictionary *keyBindingDict = [NSMutableDictionary dictionary];

    for (id item in array) {
        NSArray *children = item[CEKeyBindingChildrenKey];
        if (children) {
            NSDictionary *childDict = [self keyBindingDictionaryFromOutlineViewDataArray:children];
            [keyBindingDict addEntriesFromDictionary:childDict];
        }
        NSString *keySpecChars = item[CEKeyBindingKeySpecCharsKey];
        NSString *selectorStr = item[CEKeyBindingSelectorStringKey];
        if (([keySpecChars length] > 0) && ([selectorStr length] > 0)) {
            [keyBindingDict setValue:selectorStr forKey:keySpecChars];
        }
    }
    return keyBindingDict;
}


//------------------------------------------------------
/// セレクタ名を定義しているキーバインディング文字列（キー）を得る
- (NSString *)keySpecCharsInDictionaryFromSelectorString:(NSString *)selectorString
//------------------------------------------------------
{
    NSArray *keys = [[self menuKeyBindingDict] allKeysForObject:selectorString];
    
    return ([keys count] > 0) ? keys[0] : @"";
}



#pragma mark Private Class Methods

//=======================================================
// Private method
//
//=======================================================

//------------------------------------------------------
/// メニューのキーボードショートカットから表示用文字列を返す
+ (NSString *)printableKeyStringsFromKeyEquivalent:(NSString *)string
//------------------------------------------------------
{
    if ([string length] < 1) { return @""; }
    
    unichar theChar = [string characterAtIndex:0];
    if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:theChar]) {
        return [string uppercaseString];
    } else {
        return [CEKeyBindingManager printableCharFromIgnoringModChar:string];
    }
}

//------------------------------------------------------
/// キーバインディング定義文字列から表示用モディファイアキー文字列を生成し、返す
+ (NSString *)printableKeyStringFromModKeySpecChars:(NSString *)modString withShiftKey:(BOOL)drawsShiftKey
//------------------------------------------------------
{
    NSCharacterSet *modStringSet = [NSCharacterSet characterSetWithCharactersInString:modString];
    NSMutableString *keyStrings = [NSMutableString string];
    
    for (NSUInteger i = 0; i < kSizeOfModifierKeys; i++) {
        unichar theChar = kKeySpecCharList[i];
        if ([modStringSet characterIsMember:theChar] || ((i == CEShiftKeyIndex) && drawsShiftKey)) {
            [keyStrings appendFormat:@"%C", kModifierKeySymbolCharList[i]];
        }
    }
    
    return keyStrings;
}


//------------------------------------------------------
/// キーバインディング定義文字列またはキーボードショートカットキーからキー表示用文字列を生成し、返す
+ (NSString *)printableCharFromIgnoringModChar:(NSString *)modCharString
//------------------------------------------------------
{
    return kUnprintableKeyTable[modCharString] ? : modCharString;
}


//------------------------------------------------------
/// そのまま表示できないキーバインディング定義文字列の変換辞書を返す
+ (NSDictionary *)unprintableKeyDictionary
//------------------------------------------------------
{
    // 下記の情報を参考にさせていただきました (2005.09.05)
    // http://www.cocoabuilder.com/archive/message/2004/3/19/102023
    NSArray *printableChars = @[[NSString stringWithFormat:@"%C", (unichar)0x2191], // "↑" NSUpArrowFunctionKey,
                                [NSString stringWithFormat:@"%C", (unichar)0x2193], // "↓" NSDownArrowFunctionKey,
                                [NSString stringWithFormat:@"%C", (unichar)0x2190], // "←" NSLeftArrowFunctionKey,
                                [NSString stringWithFormat:@"%C", (unichar)0x2192], // "→" NSRightArrowFunctionKey,
                                @"F1", // NSF1FunctionKey,
                                @"F2", // NSF2FunctionKey,
                                @"F3", // NSF3FunctionKey,
                                @"F4", // NSF4FunctionKey,
                                @"F5", // NSF5FunctionKey,
                                @"F6", // NSF6FunctionKey,
                                @"F7", // NSF7FunctionKey,
                                @"F8", // NSF8FunctionKey,
                                @"F9", // NSF9FunctionKey,
                                @"F10", // NSF10FunctionKey,
                                @"F11", // NSF11FunctionKey,
                                @"F12", // NSF12FunctionKey,
                                @"F13", // NSF13FunctionKey,
                                @"F14", // NSF14FunctionKey,
                                @"F15", // NSF15FunctionKey,
                                @"F16", // NSF16FunctionKey,
                                [NSString stringWithFormat:@"%C", (unichar)0x2326], // NSDeleteCharacter = "Delete forward"
                                [NSString stringWithFormat:@"%C", (unichar)0x2196], // "↖" NSHomeFunctionKey,
                                [NSString stringWithFormat:@"%C", (unichar)0x2198], // "↘" NSEndFunctionKey,
                                [NSString stringWithFormat:@"%C", (unichar)0x21DE], // "⇞" NSPageUpFunctionKey,
                                [NSString stringWithFormat:@"%C", (unichar)0x21DF], // "⇟" NSPageDownFunctionKey,
                                [NSString stringWithFormat:@"%C", (unichar)0x2327], // "⌧" NSClearLineFunctionKey,
                                @"Help", // NSHelpFunctionKey,
                                @"Space", // "Space",
                                [NSString stringWithFormat:@"%C", (unichar)0x21E5], // "Tab"
                                [NSString stringWithFormat:@"%C", (unichar)0x21A9], // "Return"
                                [NSString stringWithFormat:@"%C", (unichar)0x232B], // "⌫" "Backspace"
                                [NSString stringWithFormat:@"%C", (unichar)0x2305], // "Enter"
                                [NSString stringWithFormat:@"%C", (unichar)0x21E4], // "Backtab"
                                [NSString stringWithFormat:@"%C", (unichar)0x238B]];
    
    NSAssert(kSizeOfUnprintableKeyList == [printableChars count],
             @"Internal data error! Sizes of 'kUnprintableKeyList' and 'printableChars' are different.");
    
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:kSizeOfUnprintableKeyList];
    for (NSInteger i = 0; i < kSizeOfUnprintableKeyList; i++) {
        [keys addObject:[NSString stringWithFormat:@"%C", kUnprintableKeyList[i]]];
    }

    return [NSDictionary dictionaryWithObjects:printableChars forKeys:keys];
}


//------------------------------------------------------
/// 独自定義のセレクタ名配列を返す
+ (NSArray *)textKeyBindingSelectorStrArray
//------------------------------------------------------
{
    return @[@"insertCustomText_00:",
             @"insertCustomText_01:",
             @"insertCustomText_02:",
             @"insertCustomText_03:",
             @"insertCustomText_04:",
             @"insertCustomText_05:",
             @"insertCustomText_06:",
             @"insertCustomText_07:",
             @"insertCustomText_08:",
             @"insertCustomText_09:",
             @"insertCustomText_10:",
             @"insertCustomText_11:",
             @"insertCustomText_12:",
             @"insertCustomText_13:",
             @"insertCustomText_14:",
             @"insertCustomText_15:",
             @"insertCustomText_16:",
             @"insertCustomText_17:",
             @"insertCustomText_18:",
             @"insertCustomText_19:",
             @"insertCustomText_20:",
             @"insertCustomText_21:",
             @"insertCustomText_22:",
             @"insertCustomText_23:",
             @"insertCustomText_24:",
             @"insertCustomText_25:",
             @"insertCustomText_26:",
             @"insertCustomText_27:",
             @"insertCustomText_28:",
             @"insertCustomText_29:",
             @"insertCustomText_30:"];
}


//------------------------------------------------------
/// 変更しない項目のセレクタ名配列を返す
+ (NSArray *)selectorStringsToIgnore
//------------------------------------------------------
{
    return @[@"modifyFont:",
             @"changeEncoding:",
             @"changeSyntaxStyle:",
             @"changeTheme:",
             @"makeKeyAndOrderFront:",
             @"launchScript:",
             @"_openRecentDocument:",  // = 10.3 の「最近開いた書類」
             @"orderFrontCharacterPalette:"  // = 10.4「特殊文字…」
             ];
}

@end




#pragma mark -

@implementation CEKeyBindingManager (Migration)

//------------------------------------------------------
/// ユーザのメニューキーバインディング設定をいったん削除する
- (BOOL)resetMenuKeyBindings
//------------------------------------------------------
{
    // 以前の CotEditor ではユーザがカスタムをしているしていないに関わらずメニューキーバインディングの設定が
    // ユーザ領域に作成されていたため最初にインストールしたバージョン以降でデフォルトのショートカットやメソッド名が
    // 変更された場合にそれに追従できなかった。
    // その負のサイクルを断ち切るために、過去の設定ファイルを一旦削除をする。
    
    BOOL success = NO;
    NSURL *URL = [self menuKeyBindingSettingFileURL];
    
    if ([URL checkResourceIsReachableAndReturnError:nil]) {
        success = [[NSFileManager defaultManager] removeItemAtURL:URL error:nil];
        [[CEKeyBindingManager sharedManager] setupAtLaunching];
    }
    
    return success;
}

@end
