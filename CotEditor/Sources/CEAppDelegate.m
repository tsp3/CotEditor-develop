/*
 ==============================================================================
 CEAppDelegate
 
 CotEditor
 http://coteditor.com
 
 Created on 2004-12-13 by nakamuxu
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

#import "CEAppDelegate.h"
#import "CESyntaxManager.h"
#import "CEEncodingManager.h"
#import "CEKeyBindingManager.h"
#import "CEScriptManager.h"
#import "CEThemeManager.h"
#import "CEHexColorTransformer.h"
#import "CEByteCountTransformer.h"
#import "CELineHeightTransformer.h"
#import "CEPreferencesWindowController.h"
#import "CEOpacityPanelController.h"
#import "CELineHightPanelController.h"
#import "CEColorCodePanelController.h"
#import "CEScriptErrorPanelController.h"
#import "CEUnicodeInputPanelController.h"
#import "CEMigrationWindowController.h"
#import "SWFSemanticVersion.h"
#import "constants.h"


@interface CEAppDelegate ()

@property (nonatomic) BOOL didFinishLaunching;

@property (nonatomic) BOOL hasSetting;  // for migration check
@property (nonatomic) CEMigrationWindowController *migrationWindowController;


// readonly
@property (readwrite, nonatomic) NSURL *supportDirectoryURL;

@end



@interface CEAppDelegate (Migration)

- (void)migrateIfNeeded;
- (void)migrateBundleIdentifier;

@end




#pragma mark -

@implementation CEAppDelegate

#pragma mark Class Methods

//=======================================================
// Class method
//
//=======================================================

// ------------------------------------------------------
/// set binding keys and values
+ (void)initialize
// ------------------------------------------------------
{
    // Encoding list
    NSMutableArray *encodings = [[NSMutableArray alloc] initWithCapacity:kSizeOfCFStringEncodingList];
    for (NSUInteger i = 0; i < kSizeOfCFStringEncodingList; i++) {
        [encodings addObject:@(kCFStringEncodingList[i])];
    }
    
    NSDictionary *defaults = @{CEDefaultLayoutTextVerticalKey: @NO,
                               CEDefaultSplitViewVerticalKey: @NO,
                               CEDefaultShowLineNumbersKey: @YES,
                               CEDefaultShowStatusBarKey: @YES,
                               CEDefaultShowStatusBarLinesKey: @YES,
                               CEDefaultShowStatusBarLengthKey: @NO,
                               CEDefaultShowStatusBarCharsKey: @YES,
                               CEDefaultShowStatusBarWordsKey: @NO,
                               CEDefaultShowStatusBarLocationKey: @YES,
                               CEDefaultShowStatusBarLineKey: @YES,
                               CEDefaultShowStatusBarColumnKey: @NO,
                               CEDefaultShowStatusBarEncodingKey: @NO,
                               CEDefaultShowStatusBarLineEndingsKey: @NO,
                               CEDefaultShowStatusBarFileSizeKey: @YES,
                               CEDefaultShowNavigationBarKey: @YES,
                               CEDefaultCountLineEndingAsCharKey: @YES,
                               CEDefaultSyncFindPboardKey: @NO,
                               CEDefaultInlineContextualScriptMenuKey: @NO,
                               CEDefaultWrapLinesKey: @YES,
                               CEDefaultLineEndCharCodeKey: @0,
                               CEDefaultEncodingListKey: encodings,
                               CEDefaultFontNameKey: [[NSFont controlContentFontOfSize:[NSFont systemFontSize]] fontName],
                               CEDefaultFontSizeKey: @([NSFont systemFontSize]),
                               CEDefaultEncodingInOpenKey: @(CEAutoDetectEncodingMenuItemTag),
                               CEDefaultEncodingInNewKey: @(CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8)),
                               CEDefaultReferToEncodingTagKey: @YES,
                               CEDefaultCreateNewAtStartupKey: @YES,
                               CEDefaultReopenBlankWindowKey: @YES,
                               CEDefaultCheckSpellingAsTypeKey: @NO,
                               CEDefaultWindowWidthKey: @600.0f,
                               CEDefaultWindowHeightKey: @450.0f,
                               CEDefaultWindowAlphaKey: @1.0f,
                               CEDefaultAutoExpandTabKey: @NO,
                               CEDefaultTabWidthKey: @4U,
                               CEDefaultAutoIndentKey: @YES,
                               CEDefaultShowInvisibleSpaceKey: @NO,
                               CEDefaultInvisibleSpaceKey: @0U,
                               CEDefaultShowInvisibleTabKey: @NO,
                               CEDefaultInvisibleTabKey: @0U,
                               CEDefaultShowInvisibleNewLineKey: @NO,
                               CEDefaultInvisibleNewLineKey: @0U,
                               CEDefaultShowInvisibleFullwidthSpaceKey: @NO,
                               CEDefaultInvisibleFullwidthSpaceKey: @0U,
                               CEDefaultShowOtherInvisibleCharsKey: @NO,
                               CEDefaultHighlightCurrentLineKey: @NO,
                               CEDefaultThemeKey: @"Dendrobates",
                               CEDefaultEnableSyntaxHighlightKey: @YES,
                               CEDefaultSyntaxStyleKey: NSLocalizedString(@"None", nil),
                               CEDefaultDelayColoringKey: @NO,
                               CEDefaultFileDropArrayKey: @[@{CEFileDropExtensionsKey: @"jpg, jpeg, gif, png",
                                                              CEFileDropFormatStringKey: @"<img src=\"<<<RELATIVE-PATH>>>\" alt=\"<<<FILENAME-NOSUFFIX>>>\" title=\"<<<FILENAME-NOSUFFIX>>>\" width=\"<<<IMAGEWIDTH>>>\" height=\"<<<IMAGEHEIGHT>>>\" />"}],
                               CEDefaultSmartInsertAndDeleteKey: @NO,
                               CEDefaultEnableSmartQuotesKey: @NO,
                               CEDefaultEnableSmartIndentKey: @YES,
                               CEDefaultAppendsCommentSpacerKey: @YES,
                               CEDefaultCommentsAtLineHeadKey: @YES,
                               CEDefaultShouldAntialiasKey: @YES,
                               CEDefaultAutoCompleteKey: @NO,
                               CEDefaultCompletionWordsKey: @2U,
                               CEDefaultShowPageGuideKey: @NO,
                               CEDefaultPageGuideColumnKey: @80,
                               CEDefaultLineSpacingKey: @0.3f,
                               CEDefaultSwapYenAndBackSlashKey: @NO,
                               CEDefaultFixLineHeightKey: @YES,
                               CEDefaultHighlightBracesKey: @YES,
                               CEDefaultHighlightLtGtKey: @NO,
                               CEDefaultSaveUTF8BOMKey: @NO,
                               CEDefaultSetPrintFontKey: @0,
                               CEDefaultPrintFontNameKey: [[NSFont controlContentFontOfSize:[NSFont systemFontSize]] fontName],
                               CEDefaultPrintFontSizeKey: @([NSFont systemFontSize]),
                               CEDefaultPrintHeaderKey: @YES,
                               CEDefaultHeaderOneStringIndexKey: @3,
                               CEDefaultHeaderTwoStringIndexKey: @4,
                               CEDefaultHeaderOneAlignIndexKey: @0,
                               CEDefaultHeaderTwoAlignIndexKey: @2,
                               CEDefaultPrintHeaderSeparatorKey: @YES,
                               CEDefaultPrintFooterKey: @YES,
                               CEDefaultFooterOneStringIndexKey: @0,
                               CEDefaultFooterTwoStringIndexKey: @5,
                               CEDefaultFooterOneAlignIndexKey: @0,
                               CEDefaultFooterTwoAlignIndexKey: @1,
                               CEDefaultPrintFooterSeparatorKey: @YES,
                               CEDefaultPrintLineNumIndexKey: @0,
                               CEDefaultPrintInvisibleCharIndexKey: @0,
                               CEDefaultPrintColorIndexKey: @0,
                               
                               /* -------- 以下、環境設定にない設定項目 -------- */
                               CEDefaultInsertCustomTextArrayKey: @[@"<br />\n", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",
                                                                    @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",
                                                                    @"", @"", @"", @"", @"", @"", @"", @"", @"", @""],
                               CEDefaultColorCodeTypeKey:@1,
                               
                               /* -------- 以下、隠し設定 -------- */
                               CEDefaultUsesTextFontForInvisiblesKey: @NO,
                               CEDefaultLineNumFontNameKey: @"ArialNarrow",
                               CEDefaultBasicColoringDelayKey: @0.001f, 
                               CEDefaultFirstColoringDelayKey: @0.3f, 
                               CEDefaultSecondColoringDelayKey: @0.7f,
                               CEDefaultAutoCompletionDelayKey: @0.25,
                               CEDefaultLineNumUpdateIntervalKey: @0.12f, 
                               CEDefaultInfoUpdateIntervalKey: @0.2f, 
                               CEDefaultIncompatibleCharIntervalKey: @0.42f, 
                               CEDefaultOutlineMenuIntervalKey: @0.37f, 
                               CEDefaultOutlineMenuMaxLengthKey: @110U, 
                               CEDefaultHeaderFooterFontNameKey: [[NSFont systemFontOfSize:[NSFont systemFontSize]] fontName], 
                               CEDefaultHeaderFooterFontSizeKey: @10.0f, 
                               CEDefaultHeaderFooterDateFormatKey: @"YYYY-MM-dd HH:mm",
                               CEDefaultHeaderFooterPathAbbreviatingWithTildeKey: @YES, 
                               CEDefaultTextContainerInsetWidthKey: @0.0f, 
                               CEDefaultTextContainerInsetHeightTopKey: @4.0f, 
                               CEDefaultTextContainerInsetHeightBottomKey: @16.0f, 
                               CEDefaultShowColoringIndicatorTextLengthKey: @50000U,
                               CEDefaultRunAppleScriptInLaunchingKey: @YES,
                               CEDefaultShowAlertForNotWritableKey: @YES, 
                               CEDefaultNotifyEditByAnotherKey: @YES,
                               CEDefaultColoringRangeBufferLengthKey: @5000,
                               CEDefaultLargeFileAlertThresholdKey: @(100 * pow(1024, 2)),  // 100 MB
                               };
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    // 出荷時へのリセットが必要な項目に付いては NSUserDefaultsController に初期値をセットする
    NSDictionary *initialValues = [defaults dictionaryWithValuesForKeys:@[CEDefaultEncodingListKey,
                                                                          CEDefaultInsertCustomTextArrayKey,
                                                                          CEDefaultWindowWidthKey,
                                                                          CEDefaultWindowHeightKey]];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValues];
    
    // transformer 登録
    [NSValueTransformer setValueTransformer:[[CEHexColorTransformer alloc] init]
                                    forName:@"CEHexColorTransformer"];
    [NSValueTransformer setValueTransformer:[[CEByteCountTransformer alloc] init]
                                    forName:@"CEByteCountTransformer"];
    [NSValueTransformer setValueTransformer:[[CELineHeightTransformer alloc] init]
                                    forName:@"CELineHeightTransformer"];
}



#pragma mark Superclass Methods

//=======================================================
// Superclass method
//
//=======================================================

// ------------------------------------------------------
/// 初期化
- (instancetype)init
// ------------------------------------------------------
{
    self = [super init];
    if (self) {
        [self migrateBundleIdentifier];
        
        _supportDirectoryURL = [[[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                       inDomain:NSUserDomainMask
                                                              appropriateForURL:nil
                                                                         create:NO
                                                                          error:nil]
                                URLByAppendingPathComponent:@"CotEditor"];
        
        [self setupSupportDirectory];
    }
    return self;
}


// ------------------------------------------------------
/// あとかたづけ
- (void)dealloc
// ------------------------------------------------------
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark Protocol

//=======================================================
// NSNibAwaking Protocol
//
//=======================================================

// ------------------------------------------------------
/// Nibファイル読み込み直後
- (void)awakeFromNib
// ------------------------------------------------------
{
    // build menus
    [self buildEncodingMenu];
    [self buildSyntaxMenu];
    [self buildThemeMenu];
    [[CEScriptManager sharedManager] buildScriptMenu:nil];
    
    // エンコーディングリスト更新の通知依頼
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(buildEncodingMenu)
                                                 name:CEEncodingListDidUpdateNotification
                                               object:nil];
    // シンタックススタイルリスト更新の通知依頼
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(buildSyntaxMenu)
                                                 name:CESyntaxListDidUpdateNotification
                                               object:nil];
    // テーマリスト更新の通知依頼
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(buildThemeMenu)
                                                 name:CEThemeListDidUpdateNotification
                                               object:nil];
}



#pragma mark Delegate and Notification

//=======================================================
// Delegate method (NSApplication)
//  <== File's Owner
//=======================================================

// ------------------------------------------------------
/// アプリ起動時に新規ドキュメント作成
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
// ------------------------------------------------------
{
    if (![self didFinishLaunching]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:CEDefaultCreateNewAtStartupKey];
    }
    
    return YES;
}


// ------------------------------------------------------
/// Re-Open AppleEvents へ対応してウィンドウを開くかどうかを返す
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
// ------------------------------------------------------
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CEDefaultReopenBlankWindowKey]) {
        return YES;
    }
    
    return flag;
}


// ------------------------------------------------------
/// アプリ起動直後
- (void)applicationDidFinishLaunching:(NSNotification *)notification
// ------------------------------------------------------
{
    // （CEKeyBindingManagerによって、キーボードショートカット設定は上書きされる。
    // アプリに内包する MenuKeyBindings.plist に、ショートカット設定を記述する必要がある。2007.05.19）

    // 「Select Outline item」「Goto」メニューを生成／追加
    NSMenu *findMenu = [[[NSApp mainMenu] itemAtIndex:CEFindMenuIndex] submenu];
    NSMenuItem *menuItem;

    [findMenu addItem:[NSMenuItem separatorItem]];
    unichar upKey = NSUpArrowFunctionKey;
    menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Select Prev Outline Item", nil)
                                          action:@selector(selectPrevItemOfOutlineMenu:)
                                   keyEquivalent:[NSString stringWithCharacters:&upKey length:1]];
    [menuItem setKeyEquivalentModifierMask:(NSCommandKeyMask | NSAlternateKeyMask)];
    [findMenu addItem:menuItem];

    unichar downKey = NSDownArrowFunctionKey;
    menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Select Next Outline Item", nil)
                                          action:@selector(selectNextItemOfOutlineMenu:)
                                   keyEquivalent:[NSString stringWithCharacters:&downKey length:1]];
    [menuItem setKeyEquivalentModifierMask:(NSCommandKeyMask | NSAlternateKeyMask)];
    [findMenu addItem:menuItem];

    [findMenu addItem:[NSMenuItem separatorItem]];
    menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Go To…", nil)
                                          action:@selector(gotoLocation:)
                                   keyEquivalent:@"l"];
    [findMenu addItem:menuItem];
    
    // AppleScript 起動のスピードアップのため一度動かしておく
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CEDefaultRunAppleScriptInLaunchingKey]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *source = @"tell application \"CotEditor\" to number of documents";
            NSAppleScript *AppleScript = [[NSAppleScript alloc] initWithSource:source];
            [AppleScript executeAndReturnError:nil];
        });
    }
    
    // KeyBindingManagerをセットアップ
    [[CEKeyBindingManager sharedManager] setupAtLaunching];
    
    // 必要があれば移行処理を行う
    [self migrateIfNeeded];
    
    // store latest version
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:CEDefaultLastVersionKey];
    NSString *thisVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    SWFSemanticVersion *lastSemVer = lastVersion ? [SWFSemanticVersion semanticVersionWithString:lastVersion] : nil;
    SWFSemanticVersion *thisSemVer = [SWFSemanticVersion semanticVersionWithString:thisVersion];
    if (!lastSemVer || [lastSemVer compare:thisSemVer] == NSOrderedAscending) {  // lastVer < thisVer
        [[NSUserDefaults standardUserDefaults] setObject:thisVersion forKey:CEDefaultLastVersionKey];
    }
    
    [self setDidFinishLaunching:YES];
}


// ------------------------------------------------------
/// Dock メニュー生成
- (NSMenu *)applicationDockMenu:(NSApplication *)sender
// ------------------------------------------------------
{
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *newItem = [[[[[NSApp mainMenu] itemAtIndex:CEFileMenuIndex] submenu] itemWithTag:CENewMenuItemTag] copy];
    NSMenuItem *openItem = [[[[[NSApp mainMenu] itemAtIndex:CEFileMenuIndex] submenu] itemWithTag:CEOpenMenuItemTag] copy];

    [newItem setAction:@selector(newInDockMenu:)];
    [openItem setAction:@selector(openInDockMenu:)];

    [menu addItem:newItem];
    [menu addItem:openItem];

    return menu;
}


// ------------------------------------------------------
/// ファイルを開く
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
// ------------------------------------------------------
{
    // テーマファイルの場合はインストール処理をする
    if ([[filename pathExtension] isEqualToString:CEThemeExtension]) {
        NSURL *URL = [NSURL fileURLWithPath:filename];
        NSString *themeName = [[URL lastPathComponent] stringByDeletingPathExtension];
        NSAlert *alert;
        NSInteger returnCode;
        
        // テーマファイルをテキストファイルとして開くかを訊く
        alert = [[NSAlert alloc] init];
        [alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"“%@” is a CotEditor theme file.", nil), [URL lastPathComponent]]];
        [alert setInformativeText:NSLocalizedString(@"Do you want to install this theme?", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Install", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Open as Text File", nil)];
        
        returnCode = [alert runModal];
        if (returnCode == NSAlertSecondButtonReturn) {  // Edit as Text File
            return NO;
        }
        
        // テーマ読み込みを実行
        NSError *error = nil;
        [[CEThemeManager sharedManager] importTheme:URL replace:NO error:&error];
        
        // すでに同名のテーマが存在する場合は置き換えて良いかを訊く
        if ([error code] == CEThemeFileDuplicationError) {
            alert = [NSAlert alertWithError:error];
            
            returnCode = [alert runModal];
            if (returnCode == NSAlertFirstButtonReturn) {  // Canceled
                return YES;
            } else {
                error = nil;
                [[CEThemeManager sharedManager] importTheme:URL replace:YES error:&error];
            }
        }
        
        if (error) {
            alert = [NSAlert alertWithError:error];
        } else {
            [[NSSound soundNamed:@"Glass"] play];
            alert = [[NSAlert alloc] init];
            [alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"A new theme named “%@” has been successfully installed.", nil), themeName]];
        }
        [alert runModal];
        
        return YES;
    }
    
    return NO;
}


// ------------------------------------------------------
/// メニューの有効化／無効化を制御
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
// ------------------------------------------------------
{
    if (([menuItem action] == @selector(showLineHeightPanel:)) ||
        ([menuItem action] == @selector(showUnicodeInputPanel:))) {
        return ([[NSDocumentController sharedDocumentController] currentDocument] != nil);
    }
    
    return YES;
}



#pragma mark Action Messages

//=======================================================
// Action messages
//
//=======================================================

// ------------------------------------------------------
/// 環境設定ウィンドウを開く
- (IBAction)showPreferences:(id)sender
// ------------------------------------------------------
{
    [[CEPreferencesWindowController sharedController] showWindow:self];
}


// ------------------------------------------------------
/// Scriptエラーウィンドウを表示
- (IBAction)showScriptErrorPanel:(id)sender
// ------------------------------------------------------
{
    [[CEScriptErrorPanelController sharedController] showWindow:self];
}


// ------------------------------------------------------
/// カラーコードウィンドウを表示
- (IBAction)showHexColorCodeEditor:(id)sender
// ------------------------------------------------------
{
    [[CEColorCodePanelController sharedController] showWindow:self];
}


// ------------------------------------------------------
/// 不透明度パネルを開く
- (IBAction)showOpacityPanel:(id)sender
// ------------------------------------------------------
{
    [[CEOpacityPanelController sharedController] showWindow:self];
}


// ------------------------------------------------------
/// 行高設定パネルを開く
- (IBAction)showLineHeightPanel:(id)sender
// ------------------------------------------------------
{
    [[CELineHightPanelController sharedController] showWindow:self];
}


// ------------------------------------------------------
/// Unicode 入力パネルを開く
- (IBAction)showUnicodeInputPanel:(id)sender
// ------------------------------------------------------
{
    [[CEUnicodeInputPanelController sharedController] showWindow:self];
}


// ------------------------------------------------------
/// アップルスクリプト辞書をスクリプトエディタで開く
- (IBAction)openAppleScriptDictionary:(id)sender
// ------------------------------------------------------
{
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"openDictionary" withExtension:@"applescript"];
    NSAppleScript *AppleScript = [[NSAppleScript alloc] initWithContentsOfURL:URL error:nil];
    [AppleScript executeAndReturnError:nil];
}


// ------------------------------------------------------
/// Dockメニューの「新規」メニューアクション（まず自身をアクティベート）
- (IBAction)newInDockMenu:(id)sender
// ------------------------------------------------------
{
    [NSApp activateIgnoringOtherApps:YES];
    [[NSDocumentController sharedDocumentController] newDocument:nil];
}


// ------------------------------------------------------
/// Dockメニューの「開く」メニューアクション（まず自身をアクティベート）
- (IBAction)openInDockMenu:(id)sender
// ------------------------------------------------------
{
    [NSApp activateIgnoringOtherApps:YES];
    [[NSDocumentController sharedDocumentController] openDocument:nil];
}


// ------------------------------------------------------
/// 任意のヘルプコンテンツを開く
- (IBAction)openHelpAnchor:(id)sender
// ------------------------------------------------------
{
    NSString *bookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
    
    [[NSHelpManager sharedHelpManager] openHelpAnchor:kHelpAnchors[[sender tag]]
                                               inBook:bookName];
    
}


// ------------------------------------------------------
/// 付属ドキュメントを開く
- (IBAction)openBundledDocument:(id)sender
// ------------------------------------------------------
{
    NSString *fileName = kBundledDocumentFileNames[[sender tag]];
    NSURL *URL = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"rtf"];
    
    [[NSWorkspace sharedWorkspace] openURL:URL];
}


// ------------------------------------------------------
/// Webサイト（coteditor.com）を開く
- (IBAction)openWebSite:(id)sender
// ------------------------------------------------------
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kWebSiteURL]];
}


// ------------------------------------------------------
/// バグを報告する
- (IBAction)reportBug:(id)sender
// ------------------------------------------------------
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kIssueTrackerURL]];
}


// ------------------------------------------------------
/// バグレポートを作成する
- (IBAction)createBugReport:(id)sender
// ------------------------------------------------------
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *URL = [bundle URLForResource:@"ReportTemplate" withExtension:@"md"];
    NSString *template = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
    
    template = [template stringByReplacingOccurrencesOfString:@"%BUNDLE_VERSION%"
                                                   withString:[bundle objectForInfoDictionaryKey:@"CFBundleVersion"]];
    template = [template stringByReplacingOccurrencesOfString:@"%SHORT_VERSION%"
                                                   withString:[bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    template = [template stringByReplacingOccurrencesOfString:@"%SYSTEM_VERSION%"
                                                   withString:[[NSProcessInfo processInfo] operatingSystemVersionString]];
    
    CEDocument *document = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:nil];
    [document doSetSyntaxStyle:@"Markdown"];
    [[document editor] setString:template];
    [[[document windowController] window] setTitle:NSLocalizedString(@"Bug Report", nil)];
}



#pragma mark Private Methods

//=======================================================
// Private method
//
//=======================================================

//------------------------------------------------------
/// データ保存用ディレクトリの存在をチェック、なければつくる
- (void)setupSupportDirectory
//------------------------------------------------------
{
    NSURL *URL = [self supportDirectoryURL];
    NSNumber *isDirectory;
    if (![URL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil]) {
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:URL
                                                withIntermediateDirectories:YES
                                                                 attributes:nil
                                                                      error:nil];
        if (!success) {
            NSLog(@"Failed to create support directory for CotEditor...");
        }
    } else if (![isDirectory boolValue]) {
        NSLog(@"\"%@\" is not dir.", URL);
    } else {
        [self setHasSetting:YES];
    }
}


//------------------------------------------------------
/// メインメニューのエンコーディングメニューアイテムを再構築
- (void)buildEncodingMenu
//------------------------------------------------------
{
    NSMenu *menu = [[[[[NSApp mainMenu] itemAtIndex:CEFormatMenuIndex] submenu] itemWithTag:CEFileEncodingMenuItemTag] submenu];
    [menu removeAllItems];
    
    NSArray *items = [[CEEncodingManager sharedManager] encodingMenuItems];
    for (NSMenuItem *item in items) {
        [item setAction:@selector(changeEncoding:)];
        [item setTarget:nil];
        [menu addItem:item];
    }
}


//------------------------------------------------------
/// メインメニューのシンタックスカラーリングメニューを再構築
- (void)buildSyntaxMenu
//------------------------------------------------------
{
    NSMenu *menu = [[[[[NSApp mainMenu] itemAtIndex:CEFormatMenuIndex] submenu] itemWithTag:CESyntaxMenuItemTag] submenu];
    [menu removeAllItems];
    
    // None を追加
    [menu addItemWithTitle:NSLocalizedString(@"None", nil)
                    action:@selector(changeSyntaxStyle:)
             keyEquivalent:@""];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    // シンタックススタイルをラインナップ
    NSArray *styleNames = [[CESyntaxManager sharedManager] styleNames];
    for (NSString *styleName in styleNames) {
        [menu addItemWithTitle:styleName
                        action:@selector(changeSyntaxStyle:)
                 keyEquivalent:@""];
    }
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    // 全文字列を再カラーリングするメニューを追加
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Re-Color All", nil)
                                                  action:@selector(recolorAll:)
                                           keyEquivalent:@"r"];
    [item setKeyEquivalentModifierMask:(NSCommandKeyMask | NSAlternateKeyMask)]; // = Cmd + Opt + R
    [menu addItem:item];
}


//------------------------------------------------------
/// メインメニューのテーマメニューを再構築
- (void)buildThemeMenu
//------------------------------------------------------
{
    NSMenu *menu = [[[[[NSApp mainMenu] itemAtIndex:CEFormatMenuIndex] submenu] itemWithTag:CEThemeMenuItemTag] submenu];
    [menu removeAllItems];
    
    NSArray *themeNames = [[CEThemeManager sharedManager] themeNames];
    for (NSString *themeName in themeNames) {
        [menu addItemWithTitle:themeName
                        action:@selector(changeTheme:)
                 keyEquivalent:@""];
    }
}

@end




#pragma mark -

@implementation CEAppDelegate (Migration)

static NSString *const kOldIdentifier = @"com.aynimac.CotEditor";
static NSString *const kMigrationFlagKey = @"isMigratedToNewBundleIdentifier";


//------------------------------------------------------
/// 必要があればCotEditor 1.x系からの移行処理を行う
- (void)migrateIfNeeded
//------------------------------------------------------
{
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:CEDefaultLastVersionKey];
    
    if (!lastVersion && [self hasSetting]) {
        [self migrateToVersion2];
    }
}


//------------------------------------------------------
/// perform migration from CotEditor 1.x to 2.0
- (void)migrateToVersion2
//------------------------------------------------------
{
    // show migration window
    CEMigrationWindowController *windowController = [[CEMigrationWindowController alloc] init];
    [self setMigrationWindowController:windowController];
    [windowController showWindow:self];
    
    // reset menu keybindings setting
    [windowController setInformative:@"Restorering menu key bindings settings…"];
    [[CEKeyBindingManager sharedManager] resetMenuKeyBindings];
    [windowController progressIndicator];
    [windowController setDidResetKeyBindings:YES];
    
    // migrate coloring setting
    [windowController setInformative:@"Migrating coloring settings…"];
    BOOL didMigrate = [[CEThemeManager sharedManager] migrateTheme];
    [windowController progressIndicator];
    [windowController setDidMigrateTheme:didMigrate];
    
    // migrate syntax styles to modern style
    [windowController setInformative:@"Migrating user syntax styles…"];
    [[CESyntaxManager sharedManager] migrateStylesWithCompletionHandler:^(BOOL success) {
        [windowController setDidMigrateSyntaxStyles:success];
        
        [windowController setInformative:@"Migration finished."];
        [windowController setMigrationFinished:YES];
    }];
}


//------------------------------------------------------
/// copy user defaults from com.aynimac.CotEditor
- (void)migrateBundleIdentifier
//------------------------------------------------------
{
    NSUserDefaults *oldDefaults = [[NSUserDefaults alloc] init];
    NSMutableDictionary *oldDefaultsDict = [[oldDefaults persistentDomainForName:kOldIdentifier] mutableCopy];
    
    if (!oldDefaultsDict || [oldDefaultsDict[kMigrationFlagKey] boolValue]) { return; }
    
    // remove deprecated setting key with "NS"-prefix
    [oldDefaultsDict removeObjectForKey:@"NSDragAndDropTextDelay"];
    
    // copy to current defaults
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:oldDefaultsDict
                                                       forName:[[NSBundle mainBundle] bundleIdentifier]];
    
    // set migration flag to old defaults
    oldDefaultsDict[kMigrationFlagKey] = @(YES);
    [oldDefaults setPersistentDomain:oldDefaultsDict forName:kOldIdentifier];
}

@end
