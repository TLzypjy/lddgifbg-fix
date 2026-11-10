// 灵动岛背景美化 —— 重制版设置 Bundle (v3: 全标准 ObjC 语法, 适配 arm64e)
// 架构: 入口壳(PSListController 自绘 9 行) -> 素材选择器(1.48: 推入式第二设置页, 模态兜底)
// 关键: 全部使用 [obj method:] 标准语法, 由编译器生成 arm64e 正确的 objc_msgSend
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <stdlib.h> // 1.47: PwB 探针裁剪用 malloc

typedef struct objc_class *Class;
typedef struct objc_object { Class isa; } *id;
typedef struct objc_selector *SEL;
typedef struct CGImage *CGImageRef;
typedef bool BOOL;
typedef unsigned long NSUInteger;
typedef long NSInteger;
#define YES 1
#define NO 0
#define nil 0
#define Nil 0

extern "C" id objc_msgSend(id self, SEL op, ...);
extern "C" id objc_getClass(const char *name);
extern "C" SEL sel_registerName(const char *name);
extern "C" void *dlopen(const char *path, int mode);
extern "C" void *dlsym(void *handle, const char *symbol);
// 1.65: SDK 把 system() 标记为 iOS 不可用 -> 运行时 dlsym 取
static int (*_system_fn)(const char *) = 0;
extern "C" void CFRelease(void *cf);
extern "C" void objc_setAssociatedObject(id obj, const char *key, id value, unsigned long policy);
extern "C" id objc_getAssociatedObject(id obj, const char *key);
extern "C" int notify_post(const char *name);
extern "C" double CFAbsoluteTimeGetCurrent(void);
extern "C" id UIImageJPEGRepresentation(id img, double q);
// 1.85: 滑条拖动写盘节流的收尾补写
extern "C" long long dispatch_time(long long base, long long delta);
extern "C" void dispatch_after(long long when, void *queue, void (^block)(void));
extern "C" struct dispatch_queue_s _dispatch_main_q;

#define CLS(n) objc_getClass(n)
static id CLSSTR(const char *n) { return (id)objc_getClass(n); }

// ---------- ObjC 存根 (标准声明, 供编译期检查) ----------
@interface NSObject
+ (id)alloc;
+ (id)class;
- (id)performSelector:(SEL)s;
- (id)init;
- (id)valueForKey:(id)k;
- (void)setValue:(id)v forKey:(id)k;
- (void)performSelector:(SEL)s withObject:(id)o afterDelay:(double)d;
- (void)performSelectorOnMainThread:(SEL)s withObject:(id)o waitUntilDone:(BOOL)w;
@end
@class NSArray;
@class NSString;
@interface NSNotificationCenter : NSObject
+ (id)defaultCenter;
- (void)postNotificationName:(NSString *)n object:(id)o;
- (void)addObserver:(id)obs selector:(SEL)sel name:(NSString *)n object:(id)o;
@end
@interface NSString : NSObject
- (id)initWithBytes:(const void *)b length:(NSUInteger)l encoding:(NSUInteger)e;
+ (id)stringWithFormat:(NSString *)f, ...;
- (double)doubleValue;
- (NSString *)stringByAppendingPathComponent:(NSString *)s;
- (NSString *)pathExtension;
- (NSString *)lowercaseString;
- (NSString *)lastPathComponent;
- (BOOL)isEqualToString:(NSString *)s;
- (NSUInteger)length;
+ (id)stringWithContentsOfFile:(NSString *)path encoding:(NSUInteger)enc error:(id *)err;
- (NSArray *)componentsSeparatedByString:(NSString *)sep;
- (NSString *)stringByTrimmingCharactersInSet:(id)cs;
@end
@interface NSArray : NSObject
+ (id)array;
+ (id)arrayWithObjects:(id)first, ...;
- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)i;
- (BOOL)containsObject:(id)o;
- (id)mutableCopy;
- (NSUInteger)countByEnumeratingWithState:(void *)state objects:(id *)buf count:(NSUInteger)len;
- (id)objectAtIndexedSubscript:(NSUInteger)i;
- (NSString *)componentsJoinedByString:(NSString *)sep;
@end
@interface NSMutableArray : NSArray
+ (id)array;
+ (id)arrayWithCapacity:(NSUInteger)n;
- (void)addObject:(id)obj;
- (void)removeObject:(id)o;
- (void)removeAllObjects;
@end
@interface NSDictionary : NSObject
+ (id)dictionary;
+ (id)dictionaryWithContentsOfFile:(NSString *)p;
- (NSUInteger)count;
- (id)objectForKeyedSubscript:(id)k;
- (id)objectForKey:(id)k;
- (BOOL)writeToFile:(NSString *)p atomically:(BOOL)a;
@end
@interface NSMutableDictionary : NSDictionary
+ (id)dictionary;
- (void)addEntriesFromDictionary:(NSDictionary *)other;
- (void)setObject:(id)obj forKeyedSubscript:(id)k;
- (void)setObject:(id)obj forKey:(id)k;
- (void)removeObjectForKey:(id)k;
@end
@interface NSData : NSObject
+ (id)dataWithContentsOfFile:(NSString *)p;
@end
@interface NSNumber : NSObject
+ (id)numberWithDouble:(double)d;
+ (id)numberWithBool:(BOOL)b;
- (double)doubleValue;
- (BOOL)boolValue;
- (int)intValue;
+ (id)numberWithInt:(int)v;
@end
@interface NSFileManager : NSObject
+ (id)defaultManager;
- (BOOL)fileExistsAtPath:(NSString *)p;
- (BOOL)fileExistsAtPath:(NSString *)p isDirectory:(BOOL *)d;
- (BOOL)createDirectoryAtPath:(NSString *)p withIntermediateDirectories:(BOOL)b attributes:(id)a error:(id *)e;
- (BOOL)copyItemAtURL:(id)src toURL:(id)dst error:(id *)e;
- (BOOL)removeItemAtPath:(NSString *)p error:(id *)e;
- (BOOL)moveItemAtPath:(NSString *)p toPath:(NSString *)t error:(id *)e;
- (BOOL)createFileAtPath:(NSString *)p contents:(id)c attributes:(id)a;
- (id)contentsOfDirectoryAtPath:(NSString *)p error:(id *)e;
@end
@interface NSUserDefaults : NSObject
- (id)initWithSuiteName:(NSString *)n;
- (id)objectForKey:(id)k;
- (void)setObject:(id)obj forKey:(id)k;
- (void)removeObjectForKey:(NSString *)k;
- (BOOL)synchronize;
@end
@interface NSURL : NSObject
+ (id)fileURLWithPath:(NSString *)p;
+ (id)URLWithString:(NSString *)s;
- (NSString *)pathExtension;
@end
@interface NSIndexPath : NSObject
- (NSInteger)row;
- (NSInteger)section;
@end
@interface NSException : NSObject @end
@interface NSCharacterSet : NSObject
+ (id)whitespaceCharacterSet;
@end

typedef struct CGPoint { double x, y; } CGPoint;
typedef struct CGRect { double ox, oy, w, h; } CGRect;

typedef struct CGColor *CGColorRef;
extern "C" void *CGImageSourceCopyPropertiesAtIndex(void *src, unsigned long idx, void *opts);
extern "C" void *CGColorSpaceCreateDeviceRGB(void);
extern "C" void *CGBitmapContextCreate(void *data, unsigned long w, unsigned long h, unsigned long bpc, unsigned long bpr, void *cs, unsigned long info);
extern "C" void CGContextDrawImage(void *ctx, CGRect rect, CGImageRef img);
extern "C" void CGColorSpaceRelease(void *cs);
extern "C" void CGContextRelease(void *ctx);
// 1.81: 画小号滑块圆钮
extern "C" void *UIGraphicsGetCurrentContext(void);
extern "C" void CGContextSetRGBFillColor(void *ctx, double r, double g, double b, double a);
extern "C" void CGContextFillEllipseInRect(void *ctx, CGRect rect);
extern "C" void *kCGImagePropertyGIFDictionary;
extern "C" void *kCGImagePropertyGIFDelayTime;
extern "C" void *kCGImagePropertyGIFUnclampedDelayTime;

typedef struct CGSize { double w, h; } CGSize;
typedef struct UIEdgeInsets { double top, left, bottom, right; } UIEdgeInsets;
// 1.9.140: 预览平移
typedef struct CGAffineTransform { double a, b, c, d, tx, ty; } CGAffineTransform;
static CGAffineTransform CGMakeTranslate(double tx, double ty) { CGAffineTransform t = {1, 0, 0, 1, tx, ty}; return t; }
static CGRect MakeRect(double x, double y, double w, double h) { CGRect r = {x, y, w, h}; return r; }

@interface UIColor : NSObject
+ (id)clearColor;
+ (id)whiteColor;
+ (id)redColor;
+ (id)colorWithWhite:(double)w alpha:(double)a;
+ (id)systemBlueColor;
+ (id)colorWithWhite:(double)w alpha:(double)a;
- (CGColorRef)CGColor;
+ (id)colorWithRed:(double)r green:(double)g blue:(double)bl alpha:(double)a;
@end
@interface UIFont : NSObject
+ (id)systemFontOfSize:(double)s;
+ (id)boldSystemFontOfSize:(double)s;
@end
@interface UIView : NSObject
- (id)initWithFrame:(CGRect)r;
- (CGRect)bounds;
- (CGRect)frame;
- (void)setFrame:(CGRect)r;
- (void)addSubview:(id)v;
- (CGRect)convertRect:(CGRect)r toView:(id)v;
- (CGRect)convertRect:(CGRect)r fromView:(id)v;
// 1.9.140: 预览偏移用
- (void)setTransform:(CGAffineTransform)t;
- (void)setTag:(NSInteger)t;
- (id)viewWithTag:(NSInteger)t;
- (id)superview;
- (void)addGestureRecognizer:(id)g;
- (void)removeFromSuperview;
- (void)setBackgroundColor:(id)c;
- (id)subviews;
- (id)layer;
- (void)setContentMode:(NSInteger)m;
- (void)setTintColor:(id)c;
- (void)setClipsToBounds:(BOOL)b;
- (void)setAlpha:(double)a;
- (id)window;
- (void)setUserInteractionEnabled:(BOOL)e;
- (void)addGestureRecognizer:(id)g;
- (void)setAutoresizingMask:(NSUInteger)m;
@end

@interface UIWindow : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setWindowLevel:(long)l;
- (void)setHidden:(BOOL)h;
- (void)makeKeyAndVisible;
- (void)setWindowScene:(id)s;
- (id)scene;
- (long)windowLevel;
- (id)hitTest:(CGPoint)p withEvent:(id)e;
@end
@interface UIApplication : NSObject
+ (id)sharedApplication;
- (id)keyWindow;
- (void)openURL:(id)u options:(id)o completionHandler:(id)c;
@end
@interface UIGestureRecognizer : NSObject
- (id)initWithTarget:(id)target action:(SEL)action;
- (long)state;
- (id)view;
- (CGPoint)locationInView:(id)v;
@end
@interface UILongPressGestureRecognizer : UIGestureRecognizer
- (void)setMinimumPressDuration:(double)d;
- (void)setEnabled:(BOOL)e;
@end
@interface UIControl : UIView
- (void)addTarget:(id)t action:(SEL)a forControlEvents:(NSUInteger)e;
@end
@interface UILabel : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setText:(NSString *)t;
- (void)setFont:(id)f;
- (void)setTextColor:(id)c;
- (void)setTextAlignment:(NSInteger)a;
- (void)setAlpha:(double)a;
- (void)setNumberOfLines:(NSInteger)n;
- (void)sizeToFit;
- (CGRect)frame;
- (void)setFrame:(CGRect)r;
@end
@interface UITextField : UIControl
- (void)setPlaceholder:(NSString *)p;
- (id)text;
- (void)setText:(NSString *)t;
- (void)setKeyboardType:(NSInteger)k;
// 1.9.191: 素材网格行内改名
- (void)setFont:(id)f;
- (void)setBorderStyle:(NSInteger)s;
- (void)setReturnKeyType:(NSInteger)t;
- (void)setDelegate:(id)d;
- (void)setClearButtonMode:(NSInteger)m;
- (void)setAutocapitalizationType:(NSInteger)t;
- (void)setAutocorrectionType:(NSInteger)t;
- (void)setTextAlignment:(NSInteger)a;
- (void)becomeFirstResponder;
- (void)resignFirstResponder;
@end
// 1.9.153: 点击数值自定义输入
@interface UITapGestureRecognizer : NSObject
- (id)initWithTarget:(id)t action:(SEL)a;
- (id)view;
@end
// 1.9.185: 越狱源点击复制
@interface UIPasteboard : NSObject
+ (id)generalPasteboard;
- (void)setString:(id)s;
@end
@interface UIImage : NSObject
+ (id)imageWithContentsOfFile:(NSString *)p;
// 1.78: SF Symbol 箭头 (同灵动通知)
+ (id)systemImageNamed:(NSString *)n;
+ (id)systemImageNamed:(NSString *)n withConfiguration:(id)c;
+ (id)imageWithCGImage:(CGImageRef)cg scale:(double)s orientation:(NSInteger)o;
- (CGSize)size;
- (void)drawInRect:(CGRect)r;
- (CGImageRef)CGImage;
- (CGSize)size;
+ (id)imageWithCGImage:(CGImageRef)cg;
@end
extern "C" void UIGraphicsBeginImageContextWithOptions(CGSize sz, BOOL opaque, double scale);
extern "C" id UIGraphicsGetImageFromCurrentImageContext(void);
extern "C" void UIGraphicsEndImageContext(void);
// 1.78
@interface UIImageSymbolConfiguration : NSObject
+ (id)configurationWithPointSize:(double)p weight:(double)w;
@end
@interface UIImageView : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setImage:(id)img;
- (void)setAnimationImages:(id)images;
- (void)setAnimationDuration:(double)d;
- (void)setAnimationRepeatCount:(NSInteger)n;
- (void)startAnimating;
- (void)stopAnimating;
- (void)setAlpha:(double)a;
@end
@interface UIView (Spring)
+ (void)animateWithDuration:(double)d delay:(double)dl usingSpringWithDamping:(double)damp initialSpringVelocity:(double)vel options:(NSUInteger)opt animations:(void(^)(void))anim completion:(void(^)(BOOL))comp;
@end
@interface UIButton : UIView
- (void)addTarget:(id)t action:(SEL)a forControlEvents:(NSUInteger)e;
- (void)setTitle:(NSString *)t forState:(NSUInteger)s;
- (void)setTitleColor:(id)c forState:(NSUInteger)s;
- (void)setFont:(id)f;
@end

#ifndef UIControlEventTouchUpInside
#define UIControlEventTouchUpInside (1 << 6)
#endif
@interface UISwitch : UIView
- (id)initWithFrame:(CGRect)r;
- (void)setOn:(BOOL)on animated:(BOOL)a;
- (BOOL)isOn;
- (void)setTag:(NSInteger)t;
- (NSInteger)tag;
- (void)addTarget:(id)t action:(SEL)a forControlEvents:(NSUInteger)e;
@end
@interface UISlider : UIView
- (id)initWithFrame:(CGRect)r;
// 1.9.138: 真实 UIKit 为 float —— double 签名导致 arm64 上 value 读取错位(恒 0.00)
- (void)setMinimumValue:(float)m;
- (void)setMaximumValue:(float)m;
- (void)setValue:(float)v;
- (float)value;
- (void)setThumbImage:(id)img forState:(NSUInteger)s;
- (void)addTarget:(id)t action:(SEL)a forControlEvents:(NSUInteger)e;
@end
@interface UITableViewCell : UIView
- (id)initWithStyle:(NSInteger)style reuseIdentifier:(NSString *)ri;
- (id)contentView;
- (void)setAccessoryType:(NSInteger)t;
- (void)setSelectionStyle:(NSInteger)s;
@end
@interface UITableView : UIView
- (id)dequeueReusableCellWithIdentifier:(NSString *)ri;
- (void)deselectRowAtIndexPath:(id)ip animated:(BOOL)a;
- (id)cellForRowAtIndexPath:(id)ip;
- (CGRect)rectForRowAtIndexPath:(id)ip;
@end
@interface UIViewController : NSObject
- (void)viewWillAppear:(BOOL)a;
- (void)viewWillDisappear:(BOOL)a;
- (id)initWithNibName:(id)n bundle:(id)b;
- (id)view;
- (id)navigationItem;
- (void)setTitleView:(id)v;
- (id)titleView;
- (void)setLeftBarButtonItem:(id)b;
- (void)setRightBarButtonItem:(id)b;
- (void)setRightBarButtonItems:(id)items;
- (void)setTitle:(NSString *)t;
- (void)viewDidLoad;
- (void)viewDidLayoutSubviews;
- (void)viewDidAppear:(BOOL)a;
- (void)presentViewController:(id)vc animated:(BOOL)a completion:(id)c;
- (void)dismissViewControllerAnimated:(BOOL)a completion:(id)c;
- (id)presentingViewController;
- (id)navigationController;
@end
@interface UITableViewController : UIViewController
- (id)initWithStyle:(NSInteger)style;
- (void)setTableView:(id)tv;
@end
@interface UINavigationController : UIViewController
- (id)initWithRootViewController:(id)rvc;
- (void)pushViewController:(id)vc animated:(BOOL)a;
- (void)popViewControllerAnimated:(BOOL)a;
- (id)viewControllers;
@end
@interface NSDate : NSObject
+ (id)date;
- (double)timeIntervalSince1970;
@end
@interface UIScreen : NSObject
+ (id)mainScreen;
- (CGRect)bounds;
- (double)scale;
@end
@interface UICollectionViewCell : UIView
- (id)contentView;
@end
@interface UICollectionViewFlowLayout : NSObject
- (id)init;
- (void)setMinimumInteritemSpacing:(double)s;
- (double)minimumInteritemSpacing;
- (void)setMinimumLineSpacing:(double)s;
- (void)setItemSize:(CGSize)s;
- (CGSize)itemSize;
- (void)setSectionInset:(UIEdgeInsets)i;
- (UIEdgeInsets)sectionInset;
- (void)invalidateLayout;
@end
@interface UICollectionView : UIView
- (id)initWithFrame:(CGRect)f collectionViewLayout:(id)layout;
- (id)collectionViewLayout;
- (void)setBackgroundColor:(id)c;
- (void)setDelegate:(id)d;
- (void)setDataSource:(id)d;
- (void)registerClass:(id)cls forCellWithReuseIdentifier:(NSString *)ri;
- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)ri forIndexPath:(id)ip;
- (void)reloadData;
- (id)indexPathForItemAtPoint:(CGPoint)p;
// 1.9.191: 素材网格编辑态抖动/行内改名
- (id)visibleCells;
- (id)cellForItemAtIndexPath:(id)ip;
    - (CGPoint)contentOffset;
    - (void)setContentOffset:(CGPoint)o animated:(BOOL)a;
    - (void)setContentOffset:(CGPoint)o;
    - (UIEdgeInsets)contentInset;
    - (void)setContentInset:(UIEdgeInsets)i;
    - (CGSize)contentSize;
    - (UIEdgeInsets)safeAreaInsets;
@end
@interface UIImagePickerController : UIViewController
- (void)setSourceType:(NSInteger)t;
- (void)setMediaTypes:(id)types;
- (void)setDelegate:(id)d;
- (void)setAllowsEditing:(BOOL)b;
@end
@interface UIDocumentPickerViewController : UIViewController
- (id)initForOpeningContentTypes:(id)types;
- (void)setDelegate:(id)d;
@end
@interface UNTimeIntervalNotificationTrigger : NSObject
- (id)initWithTimeInterval:(double)t repeats:(BOOL)r;
@end
@interface UNMutableNotificationContent : NSObject
- (id)init;
@end
@interface UNNotificationRequest : NSObject
- (id)initWithIdentifier:(NSString *)i content:(id)c trigger:(id)t;
@end
@interface UIAlertAction : NSObject
+ (id)actionWithTitle:(NSString *)t style:(NSInteger)s handler:(id)h;
@end
@interface UIAlertController : UIViewController
+ (id)alertControllerWithTitle:(NSString *)t message:(NSString *)m preferredStyle:(NSInteger)s;
- (void)addAction:(id)a;
- (void)addTextFieldWithConfigurationHandler:(id)h;
- (id)textFields;
@end
@interface UIBarButtonItem : NSObject
- (id)initWithTitle:(NSString *)t style:(NSInteger)s target:(id)tgt action:(SEL)a;
@end
@interface NSTimer : NSObject
+ (id)scheduledTimerWithTimeInterval:(double)t target:(id)target selector:(SEL)s userInfo:(id)info repeats:(BOOL)r;
- (id)userInfo;
- (void)invalidate;
@end
@interface CALayer : NSObject
- (void)setCornerRadius:(double)r;
- (void)setMasksToBounds:(BOOL)b;
- (void)setBorderWidth:(double)w;
- (void)setBorderColor:(CGColorRef)c;
- (void)setShadowColor:(CGColorRef)c;
- (void)setShadowOpacity:(float)o;
- (void)setShadowRadius:(double)r;
- (void)setShadowOffset:(CGSize)s;
// 1.9.191: 素材网格编辑态抖动
- (void)addAnimation:(id)a forKey:(NSString *)k;
- (void)removeAnimationForKey:(NSString *)k;
@end
// 1.9.191: 素材网格编辑态抖动动画 (属性走 KVC setValue:forKey:)
@interface CABasicAnimation : NSObject
+ (id)animationWithKeyPath:(NSString *)key;
@end
@interface PSListController : UIViewController
- (id)loadSpecifiersFromPlistName:(NSString *)n target:(id)t;
- (id)specifiers;
// 1.9.140: 素材选择返回后刷新 (预览行跟随)
- (id)table;
@end
@interface NSBundle : NSObject
+ (id)mainBundle;
+ (id)bundleForClass:(Class)c;
- (NSString *)pathForResource:(NSString *)n ofType:(NSString *)t;
- (id)objectForInfoDictionaryKey:(NSString *)k;
@end


// ---------- prefs 文件直写 (保证 SB 文件优先读取到最新值) ----------
static void WritePrefsFile(NSString *key, id value) {
    const char *paths[] = {
        "/var/jb/User/Library/Preferences/lddgifbg.plist",
        "/var/mobile/Library/Preferences/lddgifbg.plist",
        0
    };
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    // 底: NSUserDefaults 全键 (面板写过的一定在)
    NSUserDefaults *ud0 = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    for (NSString *k in [NSArray arrayWithObjects:@"Enablelddgifbg", @"lddgifbgSpeed", @"lddgifbgPosX", @"lddgifbgPosY", @"lddgifbgRandom", @"SelectedMaterialFolder", nil]) {
        id v = [ud0 objectForKey:k];
        if (v) [d setObject:v forKey:k];
    }
    // 叠加: 已有文件值
    for (int i = 0; paths[i]; i++) {
        NSString *p = [[NSString alloc] initWithBytes:paths[i] length:strlen(paths[i]) encoding:4];
        NSDictionary *cur = [NSDictionary dictionaryWithContentsOfFile:p];
        if (cur) { [d addEntriesFromDictionary:cur]; break; }
    }
    [d setObject:value forKey:key];
    for (int i = 0; paths[i]; i++) {
        NSString *p = [[NSString alloc] initWithBytes:paths[i] length:strlen(paths[i]) encoding:4];
        [d writeToFile:p atomically:YES];
    }
}

// ---------- 日志(诊断) ----------
// 1.67: 按用户要求只保留 __plugin_probe__.txt —— bundle 日志文件不再生成(空函数保留调用点)
static void LogB(const char *s) {
    (void)s;
}
// 素材库布局探针: 写入用户可直接回传的 __plugin_probe__.txt (与主逻辑 ProbeWrite 同文件)
// 1.47: 与主插件同款按行滚动裁剪 —— 超过 1000 行保留最新 900 行
static int PwBCountLines(const char *path) {
    FILE *rf = fopen(path, "rb");
    if (!rf) return 0;
    char buf[65536];
    size_t got;
    int n = 0;
    while ((got = fread(buf, 1, sizeof(buf), rf)) > 0) {
        for (size_t i = 0; i < got; i++) if (buf[i] == '\n') n++;
    }
    fclose(rf);
    return n;
}
static void PwB(const char *s) {
    static int sPwBLines = -1; // 进程内行数计数, 首次调用时数一遍现有文件
    if (sPwBLines < 0) sPwBLines = PwBCountLines("/var/mobile/lddgifbg/__plugin_probe__.txt");
    if (++sPwBLines > 1000) {
        sPwBLines = 900; // 保留最新 900 行
        FILE *rf = fopen("/var/mobile/lddgifbg/__plugin_probe__.txt", "rb");
        if (rf) {
            fseek(rf, 0, SEEK_END);
            long sz = ftell(rf);
            fseek(rf, 0, SEEK_SET);
            char *buf = (char *)malloc((size_t)sz + 1);
            if (buf) {
                size_t got = fread(buf, 1, (size_t)sz, rf);
                fclose(rf);
                long cut = 0;
                int seen = 0;
                for (long i = (long)got - 1; i >= 0; i--) {
                    if (buf[i] == '\n') { seen++; if (seen >= 900) { cut = i + 1; break; } }
                }
                if (cut > 0) {
                    FILE *wf = fopen("/var/mobile/lddgifbg/__plugin_probe__.txt", "wb");
                    if (wf) { fwrite(buf + cut, 1, got - (size_t)cut, wf); fclose(wf); }
                }
                free(buf);
            } else { fclose(rf); }
        }
    }
    FILE *f = fopen("/var/mobile/lddgifbg/__plugin_probe__.txt", "a");
    if (f) { fprintf(f, "%s\n", s ? s : "?"); fflush(f); fclose(f); }
}


// ---------- 测试通知 (独立函数, 全程防护) ----------
static void PostTestNotification(void) {
    LogB("TN-FLAG-WRITE");
    @try {
        // 写触发文件, 由 SpringBoard 侧代发通知 (设置进程无通知资格)
        [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/lddgifbg/__test_notif__" contents:0 attributes:0];
        LogB("TN-FLAG-OK");
    } @catch (id e) { LogB("TN-FLAG-EXC"); }
}

// ---------- 1.9.140: 设置页实时预览 (灵动岛药丸 + 素材首帧 + 偏移平移) ----------
static UIView *gPrevContainer = nil;
static UIImageView *gPrevContent = nil;
static double gPrevW = 0, gPrevH = 0;
static NSString *SelectedMaterialPathForPreview(void) {
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    NSString *folder = [ud objectForKey:@"SelectedMaterialFolder"];
    if (!folder) return nil;
    NSString *dir = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:folder];
    NSArray *items = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:0];
    for (NSString *it in items) {
        NSString *e = [[it pathExtension] lowercaseString];
        if ([e isEqualToString:@"gif"] || [e isEqualToString:@"mp4"] || [e isEqualToString:@"mov"])
            return [dir stringByAppendingPathComponent:it];
    }
    return nil;
}
static void LDDUpdatePreview(void) {
    if (!gPrevContainer || !gPrevContent) return;
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    id vx = [ud objectForKey:@"lddgifbgPosX"];
    id vy = [ud objectForKey:@"lddgifbgPosY"];
    double px = vx ? [vx doubleValue] : 0.0;
    double py = vy ? [vy doubleValue] : 0.0;
    CGRect cb = [gPrevContainer bounds];
    double maxTx = 0, maxTy = 0;
    if (gPrevW > 1 && gPrevH > 1) {
        double sc = (cb.w / gPrevW) > (cb.h / gPrevH) ? (cb.w / gPrevW) : (cb.h / gPrevH);
        double rw = gPrevW * sc, rh = gPrevH * sc;
        maxTx = (rw - cb.w) / 2.0; if (maxTx < 0) maxTx = 0;
        maxTy = (rh - cb.h) / 2.0; if (maxTy < 0) maxTy = 0;
    }
    // 1.9.150: 与 main 一致, 偏移限制在素材可移范围内, 不漏黑边
    if (px > maxTx) px = maxTx;
    if (px < -maxTx) px = -maxTx;
    if (py > maxTy) py = maxTy;
    if (py < -maxTy) py = -maxTy;
    // 1.9.143: 与 main 一致, 直接改 frame 原点 (不用 transform)
    CGRect pf = [gPrevContent frame];
    double fx = (cb.w - pf.w) / 2.0 + px;
    double fy = (cb.h - pf.h) / 2.0 + py;
    [gPrevContent setFrame:MakeRect(fx, fy, pf.w, pf.h)];
    { char bl[96]; snprintf(bl, sizeof(bl), "PREVIEW-POS %.0f %.0f", px, py); LogB(bl); }
}

// ---------- 素材缩略图 ----------
static void *gImageIO = NULL;
static void *gAVF = NULL;
static void *fnCGSrcCreate = NULL, *fnCGSrcImg = NULL, *fnCGSrcCount = NULL;
static void EnsureLibs(void) {
    if (!gImageIO) {
        gImageIO = dlopen("/System/Library/Frameworks/ImageIO.framework/ImageIO", 2);
        if (gImageIO) {
            fnCGSrcCreate = dlsym(gImageIO, "CGImageSourceCreateWithData");
            fnCGSrcImg = dlsym(gImageIO, "CGImageSourceCreateImageAtIndex");
            fnCGSrcCount = dlsym(gImageIO, "CGImageSourceGetCount");
        }
    }
    if (!gAVF) gAVF = dlopen("/System/Library/Frameworks/AVFoundation.framework/AVFoundation", 2);
}
// GIF 低分辨率帧序列 (动态预览用): 最多 maxFrames 帧, 缩到 maxW 宽
__attribute__((unused)) static id GIFFramesForPath(NSString *path, int maxFrames, double maxW) {
    EnsureLibs();
    if (!gImageIO || !fnCGSrcCreate || !fnCGSrcImg) return nil;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return nil;
    void *src = ((void *(*)(void *, void *))fnCGSrcCreate)((__bridge void *)data, 0);
    if (!src) return nil;
    NSUInteger count = ((NSUInteger(*)(void *))fnCGSrcCount)(src);
    if (count == 0) { CFRelease(src); return nil; }
    if ((int)count > maxFrames) count = (NSUInteger)maxFrames;
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        CGImageRef cg = ((CGImageRef(*)(void *, NSUInteger, void *))fnCGSrcImg)(src, i, 0);
        if (!cg) continue;
        UIImage *full = [UIImage imageWithCGImage:cg scale:1.0 orientation:0];
        CFRelease((void *)cg);
        if (!full) continue;
        // 缩放到 maxW
        CGSize osz; osz.w = [full size].w; osz.h = [full size].h;
        double sc = maxW / osz.w;
        if (sc > 1.0) sc = 1.0;
        CGSize nsz; nsz.w = osz.w * sc; nsz.h = osz.h * sc;
        UIGraphicsBeginImageContextWithOptions(nsz, NO, 0.0);
        [full drawInRect:MakeRect(0, 0, nsz.w, nsz.h)];
        UIImage *small = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (small) [arr addObject:small];
    }
    CFRelease(src);
    return [arr count] > 1 ? arr : nil;
}
static id ThumbForPath(NSString *path) {
    EnsureLibs();
    NSString *ext = [[path pathExtension] lowercaseString];
    if ([ext isEqualToString:@"gif"] && gImageIO && fnCGSrcCreate && fnCGSrcImg) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data) {
            void *src = ((void *(*)(void *, void *))fnCGSrcCreate)((__bridge void *)data, 0);
            if (src) {
                CGImageRef cg = ((CGImageRef(*)(void *, NSUInteger, void *))fnCGSrcImg)(src, 0, 0);
                if (cg) {
                    UIImage *img = [UIImage imageWithCGImage:cg scale:1.0 orientation:0];
                    CFRelease((void *)cg);
                    CFRelease(src);
                    return img;
                }
                CFRelease(src);
            }
        }
        return nil;
    }
    if ([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mov"]) {
        if (gAVF) {
            NSURL *url = [NSURL fileURLWithPath:path];
            typedef id (*FnA)(id, SEL, NSURL *, id);
            FnA fna = (FnA)objc_msgSend;
            id asset = fna((id)CLSSTR("AVURLAsset"), sel_registerName("URLAssetWithURL:options:"), url, nil);
            if (asset) {
                id gen = ((id(*)(id, SEL, id))objc_msgSend)((id)CLSSTR("AVAssetImageGenerator"), sel_registerName("assetImageGeneratorWithAsset:"), asset);
                if (gen) {
                    [gen setValue:[NSNumber numberWithBool:YES] forKey:@"appliesPreferredTrackTransform"];
                    struct CMTimeRaw { long long value; int timescale; unsigned flags; long long epoch; };
                    struct CMTimeRaw t = {1, 1, 1, 0};
                    // copyCGImageAtTime:actualTime:error:  (CMTime 按值经 x2/x3)
                    typedef id (*Fn)(id, SEL, struct CMTimeRaw, void *, void *);
                    Fn fn = (Fn)objc_msgSend;
                    CGImageRef cg = (__bridge CGImageRef)(fn(gen, sel_registerName("copyCGImageAtTime:actualTime:error:"), t, 0, 0));
                    if (cg) {
                        UIImage *img = [UIImage imageWithCGImage:cg scale:1.0 orientation:0];
                        CFRelease((void *)cg);
                        return img;
                    }
                }
            }
        }
        return nil;
    }
    return [UIImage imageWithContentsOfFile:path];
}

// ---------- 素材选择器: 卡片网格 ----------
@interface LDDMaterialPickerController : UIViewController
- (NSInteger)collectionView:(id)cv numberOfItemsInSection:(NSInteger)s;
- (id)collectionView:(id)cv cellForItemAtIndexPath:(id)ip;
- (void)collectionView:(id)cv didSelectItemAtIndexPath:(id)ip;
- (void)closeTapped;
- (void)viewDidLayoutSubviews;
- (void)kbdWillShow:(id)n;
@end
// 1.9.131: 素材列表只返回"素材文件夹"(目录), 排除 __ 前缀内部文件(探针/消费标记)
static id LDDListMaterialFolders(void) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *all = [fm contentsOfDirectoryAtPath:@"/var/mobile/lddgifbg" error:nil];
    NSMutableArray *dirs = [NSMutableArray array];
    for (NSString *nm in all) {
        if (((BOOL(*)(id, SEL, id))objc_msgSend)(nm, sel_registerName("hasPrefix:"), @"__")) continue;
        NSString *fp = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:nm];
        BOOL isD = NO;
        if ([fm fileExistsAtPath:fp isDirectory:&isD] && isD) [dirs addObject:nm];
    }
    return dirs;
}

@implementation LDDMaterialPickerController
{
    id _folders;
    id _thumbs;
    id _anims;
    NSString *_sel;
    id _cv;
    id _pendImg;
    id _pendURL;
    BOOL _pendVideo;
    BOOL _editMode;
    id _activeField;
    NSString *_activeName;
    id _activeCell;
    double _preKbdOY;   // 1.9.206: beginRename 前的 contentOffset.y, 改名结束恢复滚动
    id _activeLabel; // 1.9.192: 行内改名中被隐藏的名字 label, 结束时恢复显示
    id _activeIp;    // 1.9.201: 正在改名的 cell 的 indexpath, 键盘弹出时滚动到可视区
    id _editLP;      // 1.44: 集合视图长按手势(进编辑态用) —— 编辑态期间禁用, 防长按抢占删除钮点击
}
// 1.65: 双行导航标题 —— 上行"素材库 (N)", 下行用法小字(与"素材库"三字同层, 不遮挡内容)
- (void)buildBarTitleView {
    UIView *tv = [[UIView alloc] initWithFrame:MakeRect(0, 0, 280, 38)];
    [tv setTag:991];
    UILabel *l1 = [[UILabel alloc] initWithFrame:MakeRect(0, 1, 280, 19)];
    [l1 setTag:990];
    [l1 setText:@"素材库"];
    [l1 setTextAlignment:1];
    [l1 setFont:[UIFont systemFontOfSize:16.0]];
    [l1 setTextColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
    [tv addSubview:l1];
    UILabel *l2 = [[UILabel alloc] initWithFrame:MakeRect(0, 21, 280, 13)];
    [l2 setTag:977];
    [l2 setText:@"长按进入编辑状态，支持改名 / 删除"];
    [l2 setTextAlignment:1];
    [l2 setFont:[UIFont systemFontOfSize:10.0]];
    [l2 setTextColor:[UIColor colorWithWhite:0.45 alpha:1.0]];
    [tv addSubview:l2];
    [[self navigationItem] setTitleView:tv];
}
- (void)setBarTitle:(NSString *)t {
    UIView *tv = (UIView *)[[self navigationItem] titleView];
    if (tv) {
        UILabel *l = (UILabel *)[tv viewWithTag:990];
        if (l) { [l setText:t]; return; }
    }
    [self setTitle:t];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 1.65: 双行导航标题 —— 上行"素材库 (N)", 下行用法小字(与标题同层, 不遮挡内容)
    [self buildBarTitleView];
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:0 target:self action:@selector(closeTapped)];
    [[self navigationItem] setLeftBarButtonItem:close];
    UIBarButtonItem *imp = [[UIBarButtonItem alloc] initWithTitle:@"导入" style:0 target:self action:@selector(importTapped)];
    [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:imp, nil]];
    [[self view] setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1.0]];

    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fm fileExistsAtPath:@"/var/mobile/lddgifbg" isDirectory:&isDir] && isDir) {
        _folders = LDDListMaterialFolders();
    }
    _thumbs = [NSMutableDictionary dictionary];
    _anims = [NSMutableDictionary dictionary];
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    _sel = [ud objectForKey:@"SelectedMaterialFolder"];

    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:0];
    UIEdgeInsets ins; ins.top = 14; ins.left = 16; ins.bottom = 70; ins.right = 16;
    [flow setSectionInset:ins];
    // 1.9.195: item 精确 = 行宽/3 (不含间距), 间距归零, 任何手机宽度下每行必然恰好 3 个;
    // 列间距改由卡片自身左右缩进 6pt 呈现, 不再依赖 flow 的 interitem 判定
    CGRect sb = [[UIScreen mainScreen] bounds];
    double iw = (sb.w - 32.0) / 3.0;
    double ih = (iw - 12.0) + 56.0;
    CGSize isz; isz.w = iw; isz.h = ih;
    [flow setItemSize:isz];
    CGRect vb = [[self view] bounds];
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:vb collectionViewLayout:flow];
    {
        char bl[160];
        snprintf(bl, sizeof(bl), "MAT-FLOW-A set item=%.2f x%.2f inter=0 insL=16 insR=16 viewW=%.1f", iw, ih, vb.w);
        PwB(bl);
    }
    [cv setBackgroundColor:[UIColor clearColor]];
    [cv setDelegate:self];
    [cv setDataSource:self];
    [cv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"m"];
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTapped:)];
    [lp setMinimumPressDuration:0.4];
    [cv addGestureRecognizer:lp];
    _editLP = lp;   // 1.44: 编辑态期间禁用, 防长按抢占删除钮点击
    [[self view] addSubview:cv];
    _cv = cv;
    // 1.9.201: 键盘弹出 -> 把正在改名的 cell 滚到可视区 (底两行改名不再被键盘盖住)
    // 1.9.203: 探针改写 PwB (用户回传的 __plugin_probe__.txt), 不再写 bundle.log; 加 DidShow 双保险
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbdWillShow:) name:@"UIKeyboardWillShowNotification" object:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbdDidShow:) name:@"UIKeyboardDidShowNotification" object:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbdWillHide:) name:@"UIKeyboardWillHideNotification" object:0];
    PwB("KBD-OBS-ADDED");
    NSString *cnt = [NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]];
    [self setBarTitle:cnt];
}
// 1.9.194: 布局完成后核对/强制 3 列 (探针日志 + 兜底修正)
- (void)viewDidLayoutSubviews {
    @try {
        [super viewDidLayoutSubviews];
        if (!_cv) return;
        UICollectionView *c = (UICollectionView *)_cv;
        CGRect b = [c bounds];
        UICollectionViewFlowLayout *fl = (UICollectionViewFlowLayout *)[c collectionViewLayout];
        CGSize its = [fl itemSize];
        double inter = [fl minimumInteritemSpacing];
        UIEdgeInsets si = [fl sectionInset];
        double want = (b.w - 32.0) / 3.0;
        {
            char bl[200];
            snprintf(bl, sizeof(bl), "MAT-RELAYOUT cvW=%.1f cvH=%.1f item=%.2f inter=%.1f insL=%.1f insR=%.1f want=%.2f",
                     b.w, b.h, its.w, inter, si.left, si.right, want);
            PwB(bl);
        }
        if (want > 1.0 && (its.w - want) > 1.0) {
            CGSize nz; nz.w = want; nz.h = (want - 12.0) + 56.0;
            [fl setItemSize:nz];
            [fl setMinimumInteritemSpacing:0];
            UIEdgeInsets ni; ni.top = 14; ni.left = 16; ni.bottom = 70; ni.right = 16;
            [fl setSectionInset:ni];
            [fl invalidateLayout];
            { char bl[160]; snprintf(bl, sizeof(bl), "MAT-FORCED item=%.2f inter=0", want); PwB(bl); }
        }
        // 1.65: 用法说明已移入导航栏双行标题(tag 977 在 titleView 内), 此处不再重复
    } @catch (id e) { LogB("MAT-RELAYOUT-EXC"); }
}
- (void)closeTapped {
    // 1.48: 推入式页面 -> 出栈返回; 模态兜底 -> dismiss。
    UINavigationController *nc = [self navigationController];
    if (nc && [[nc viewControllers] count] > 1) {
        [nc popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:0];
    }
}
// 1.9.191: 长按缩略图 -> 进入编辑态(全网格抖动 + 红-删除钮), 点名字 -> 行内改名 (同 cc 播放器素材库交互)
- (void)longPressTapped:(id)lp {
    if ((long)[lp state] != 1) return; // UIGestureRecognizerStateBegan
    id v = [lp view];
    CGPoint p = [lp locationInView:v];
    NSIndexPath *ip = [(UICollectionView *)_cv indexPathForItemAtPoint:p];
    if (!ip) return;
    NSInteger row = [ip row];
    if (!_folders || row >= (NSInteger)[_folders count]) return;
    [self enterEditing];
}
- (void)enterEditing {
    if (_editMode) return;
    _editMode = YES;
    [self setBarTitle:@"长按完成退出"];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:0 target:self action:@selector(exitEditing)];
    [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:done, nil]];
    [(UICollectionView *)_cv reloadData];
    // 1.44: 编辑态禁用长按手势 —— 手指按删除钮超过 0.4s 会触发长按并取消点击
    [(UILongPressGestureRecognizer *)_editLP setEnabled:NO];
    [self startJiggling];
}
- (void)exitEditing {
    if (!_editMode) return;
    if (_activeField) [_activeField resignFirstResponder]; // 保存未完成的改名
    [self stopJiggling];
    _editMode = NO;
    // 1.44: 退出编辑态恢复长按手势
    [(UILongPressGestureRecognizer *)_editLP setEnabled:YES];
    UIBarButtonItem *imp = [[UIBarButtonItem alloc] initWithTitle:@"导入" style:0 target:self action:@selector(importTapped)];
    [[self navigationItem] setRightBarButtonItems:[NSArray arrayWithObjects:imp, nil]];
    [self setBarTitle:[NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]]];
    [(UICollectionView *)_cv reloadData];
}
// 抖动动画: 挂在缩略图卡片(tag 911) layer 上, 删除钮是卡片子视图 -> 随卡片一起抖
- (void)jiggleCard:(id)card {
    id anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setValue:[NSNumber numberWithDouble:-0.03] forKey:@"fromValue"];
    [anim setValue:[NSNumber numberWithDouble:0.03] forKey:@"toValue"];
    [anim setValue:[NSNumber numberWithDouble:0.12] forKey:@"duration"];
    [anim setValue:[NSNumber numberWithBool:YES] forKey:@"autoreverses"];
    [anim setValue:[NSNumber numberWithDouble:100000] forKey:@"repeatCount"];
    [[card layer] addAnimation:anim forKey:@"lddJiggle"];
}
- (void)startJiggling {
    for (id c in [(UICollectionView *)_cv visibleCells]) {
        id card = [c viewWithTag:911];
        if (card) [self jiggleCard:card];
    }
}
- (void)stopJiggling {
    for (id c in [(UICollectionView *)_cv visibleCells]) {
        id card = [c viewWithTag:911];
        if (card) [[card layer] removeAnimationForKey:@"lddJiggle"];
    }
}
// 删除钮: 手势绑定素材名
static const char kLDDDelKey = 0;
- (void)delBtnTapped:(UITapGestureRecognizer *)g {
    NSString *name = objc_getAssociatedObject(g, &kLDDDelKey);
    if (name) [self confirmDelete:name];
}
// 1.59: 下载到相册功能已移除(用户要求; 系统限制导致体验不佳, 详见 v1.53~v1.58 历史)
// 点名字 -> 行内改名
static const char kLDDNameKey = 0;
// 1.55: 广播素材变更到 SpringBoard (立即作废素材缓存, 新素材下一次来通知马上生效)
static void LDDNotifyMatChanged(void) {
    notify_post("com.tlzypjy.github/MatChanged");
}
// 1.52 自用版: 按名字选中素材 (与点卡片选中完全一致)
- (void)selectMaterialNamed:(NSString *)name {
    if (!name || _editMode) return;
    if (!_folders) return;
    for (NSUInteger i = 0; i < [_folders count]; i++) {
        NSString *n = [_folders objectAtIndex:i];
        if ([n isEqualToString:name]) {
            _sel = name;
            NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
            [ud setObject:name forKey:@"SelectedMaterialFolder"];
            [ud synchronize];
            WritePrefsFile(@"SelectedMaterialFolder", name);
            [(UICollectionView *)_cv reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LDDMatChanged" object:0];
            LDDNotifyMatChanged();
            return;
        }
    }
}
- (void)nameTapped:(UITapGestureRecognizer *)g {
    NSString *name = objc_getAssociatedObject(g, &kLDDNameKey);
    if (!name) return;
    id pill = [g view];              // pill (名字胶囊)
    id contentV = [pill superview];  // contentView
    id cell = [contentV superview];  // cell
    if (!cell) return;
    // 1.52 自用版: 只有抖动编辑模式才能改名; 未进编辑模式点名字 = 选中该素材
    if (!_editMode) { [self selectMaterialNamed:name]; return; }
    [self beginRename:name inCell:cell atPill:pill];
}
- (void)beginRename:(NSString *)name inCell:(id)cell atPill:(id)pill {
    if (_activeField) [_activeField resignFirstResponder]; // 先结束上一次未完成的编辑
    id lab = [pill viewWithTag:922]; // 名字文字 label
    CGRect lf = [pill frame];
    if (lab) [lab setHidden:YES];
    // 1.9.201: 记住位置, 键盘弹出时滚动 (存根工程无 UICollectionView 接口 -> objc_msgSend)
    _activeIp = ((id(*)(id, SEL, id))objc_msgSend)((UICollectionView *)_cv, sel_registerName("indexPathForCell:"), cell);
    // 1.9.206: 记录滚动前位置, 改名结束恢复(用户: 改完名字预览图不会自己滚下来)
    _preKbdOY = [(UICollectionView *)_cv contentOffset].y;
    UITextField *tf = [[UITextField alloc] initWithFrame:lf];
    [tf setText:name];
    [tf setFont:[UIFont systemFontOfSize:11.0]];
    [tf setTextAlignment:1];
    [tf setBorderStyle:3];     // UITextBorderStyleRoundedRect
    [tf setReturnKeyType:9];   // UIReturnKeyDone
    [tf setClearButtonMode:2]; // UITextFieldViewModeWhileEditing
    [tf setAutocapitalizationType:0];
    [tf setAutocorrectionType:1];
    [tf setDelegate:self];
    [tf setTag:955];
    [[cell contentView] addSubview:tf];
    _activeField = tf;
    _activeName = name;
    _activeCell = cell;
    _activeLabel = lab;
    [tf becomeFirstResponder];
}
// 1.43: 键盘弹出 -> 给集合视图加底部插边(=键盘高, 让最底下两行也有滚动余量),
// 再把改名行"整体"(含名字胶囊+圆点, 底部留 46pt 余量)滚到键盘上方。
// 旧公式 offY = 行顶y - (列表高-键盘高) 只把行顶对齐键盘上沿, 行体留在键盘后面;
// 且底部无插边时最后两行滚到 maxOffset 仍够不到键盘上方 -> 用户: 最底下两行改名被键盘遮挡。
- (double)kbdTargetOffsetForCell:(UIView *)cell kbH:(double)kbH {
    UICollectionView *cv = (UICollectionView *)_cv;
    CGRect fr = [cell frame];
    CGRect cvb = [cv bounds];
    UIEdgeInsets ins = [cv contentInset];
    // 让改名行的底缘(再留 46pt 圆点空间)落在键盘上沿之上
    double want = fr.oy + fr.h + 46.0 - (cvb.h - kbH);
    double st = [cv safeAreaInsets].top;
    if (want < -st) want = -st; // 1.49: 允许滚到自然顶点(内容顶到导航栏下沿), 不再钳到 0
    CGSize csz = [cv contentSize];
    double maxOff = csz.h + ins.bottom - cvb.h;
    if (maxOff < 0) maxOff = 0;
    if (want > maxOff) want = maxOff;
    return want;
}
- (void)kbdApplyInset:(double)kbH {
    UICollectionView *cv = (UICollectionView *)_cv;
    UIEdgeInsets ins = [cv contentInset];
    ins.bottom = kbH + 8.0;
    [cv setContentInset:ins];
}
// 1.49: 统一把目标偏移夹回当前合法范围。
// 卡死根因(1.44~1.48 反复复发): 滚动视图默认 contentInsetAdjustmentBehavior=automatic,
// 顶部安全区(导航栏)本身就允许负偏移 —— 自然顶点 = -safeArea.top, 且素材一屏放得下时
// 那是唯一合法偏移; 旧恢复逻辑把目标钳到 >=0, 恰好比合法范围高出 safeTop, 偏移停在
// 越界区, 列表表现为"卡住滑动不了"。恢复目标一律经此函数, 不再手写各处 min/max。
- (double)clampOffsetY:(double)y {
    UICollectionView *cv = (UICollectionView *)_cv;
    CGSize csz = [cv contentSize];
    double minOff = -[cv safeAreaInsets].top;
    double maxOff = csz.h - [cv bounds].h;
    if (maxOff < minOff) maxOff = minOff; // 内容不满一屏: 只能停在自然顶点
    if (y < minOff) y = minOff;
    if (y > maxOff) y = maxOff;
    return y;
}
- (void)kbdWillShow:(id)n {
    if (!_activeIp) { PwB("KBD-NO-IP"); return; }
    @try {
        double kbH = 0;
        id ui = [n userInfo];
        if (ui) {
            id kbv = [ui objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
            if (kbv && ((BOOL(*)(id, SEL, SEL))objc_msgSend)(kbv, sel_registerName("respondsToSelector:"), sel_registerName("CGRectValue"))) {
                // arm64 结构体(<=16B)返回走寄存器, objc_msgSend 直接 cast CGRect 返回类型取
                CGRect kf = ((CGRect(*)(id, SEL))objc_msgSend)(kbv, sel_registerName("CGRectValue"));
                kbH = kf.h;
            }
        }
        if (kbH <= 0) { PwB("KBD-NO-H"); return; }
        [self kbdApplyInset:kbH];
        if (_activeCell) {
            double offY = [self kbdTargetOffsetForCell:(UIView *)_activeCell kbH:kbH];
            UICollectionView *cv = (UICollectionView *)_cv;
            CGPoint pt = [cv contentOffset];
            pt.y = offY;
            [cv setContentOffset:pt animated:YES];
            char kb[128]; snprintf(kb, sizeof(kb), "KBD-OFFSET-y%.0f-kb%.0f", offY, kbH);
            PwB(kb);
        } else {
            PwB("KBD-NO-CELL");
        }
        PwB("KBD-SCROLL-OK");
    } @catch (id e) { PwB("KBD-SCROLL-EXC"); }
}
// 1.9.206: 键盘完全弹出后再校正一次 (WillShow 时键盘 frame 未定, 单次滚动可能不到位)
- (void)kbdDidShow:(id)n {
    if (!_activeIp) return;
    @try {
        double kbH = 0;
        id ui = [n userInfo];
        if (ui) {
            id kbv = [ui objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
            if (kbv && ((BOOL(*)(id, SEL, SEL))objc_msgSend)(kbv, sel_registerName("respondsToSelector:"), sel_registerName("CGRectValue"))) {
                CGRect kf = ((CGRect(*)(id, SEL))objc_msgSend)(kbv, sel_registerName("CGRectValue"));
                kbH = kf.h;
            }
        }
        if (kbH <= 0) { PwB("KBD-DID-NO-H"); return; }
        [self kbdApplyInset:kbH];
        if (_activeCell) {
            double offY = [self kbdTargetOffsetForCell:(UIView *)_activeCell kbH:kbH];
            UICollectionView *cv = (UICollectionView *)_cv;
            CGPoint pt = [cv contentOffset];
            pt.y = offY;
            [cv setContentOffset:pt animated:YES];
        } else {
            PwB("KBD-NO-CELL");
        }
        PwB("KBD-DIDSHOW-OK");
    } @catch (id e) { PwB("KBD-DIDSHOW-EXC"); }
}
// 1.44: 键盘收回 -> 撤掉底部插边, 并把滚动位置恢复到改名前位置。
// 1.49: 恢复目标统一走 clampOffsetY(自然顶点 = -safeArea.top), 顶排露出特判已删 ——
// 推入式页面在自然顶点时第一排本来就完整可见, 1.46/1.47 的下移补偿不再需要。
- (void)kbdWillHide:(id)n {
    @try {
        UICollectionView *cv = (UICollectionView *)_cv;
        // 撤掉底部插边
        UIEdgeInsets ins = [cv contentInset];
        ins.bottom = 0;
        [cv setContentInset:ins];
        double target = [self clampOffsetY:_preKbdOY];
        CGPoint rp = [cv contentOffset];
        rp.y = target;
        [cv setContentOffset:rp animated:NO];
        { char kb[160]; snprintf(kb, sizeof(kb), "KBD-HIDE-target%.0f", target); PwB(kb); }
        PwB("KBD-HIDE-INSET");
    } @catch (id e) { PwB("KBD-HIDE-EXC"); }
}
- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    [tf resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)tf {
    if (tf != _activeField) return;
    NSString *old = _activeName;
    NSString *nn = [tf text];
    [tf removeFromSuperview];
    // 1.9.206: 改名结束恢复滚动位置(用户: 改完名字预览图不会自己滚下来, 一直停在上边)
    // 1.49: 恢复目标统一走 clampOffsetY(自然顶点 = -safeArea.top)。
    @try {
        UICollectionView *cv = (UICollectionView *)_cv;
        CGPoint rp = [cv contentOffset];
        rp.y = [self clampOffsetY:_preKbdOY];
        [cv setContentOffset:rp animated:YES];
        { char kb[128]; snprintf(kb, sizeof(kb), "KBD-END-target%.0f", rp.y); PwB(kb); }
    } @catch (id e) { }
    _activeField = nil;
    _activeName = nil;
    _activeCell = nil;
    _activeIp = nil;
    if (_activeLabel) { [_activeLabel setHidden:NO]; _activeLabel = nil; }
    if (old && nn && [nn length] > 0) [self doRename:old to:nn];
}
- (void)doRename:(NSString *)old to:(NSString *)newName {
    if (!newName || [newName length] == 0) return;
    // 改名目标同样净化: 防路径分隔符把目录改到素材根目录之外
    newName = [[newName componentsSeparatedByString:@"/"] componentsJoinedByString:@"-"];
    newName = [newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![newName length] || [newName isEqualToString:old]) return;
    NSString *src = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:old];
    NSString *dst = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:newName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:dst]) { [self showTip:@"已存在同名素材"]; return; }
    if ([fm moveItemAtPath:src toPath:dst error:0]) {
        _folders = LDDListMaterialFolders();
        [_thumbs removeObjectForKey:old];
        [_anims removeObjectForKey:old];
        [(UICollectionView *)_cv reloadData];
        if (_editMode) [self startJiggling]; // 改名后保持编辑态抖动
        [self setBarTitle:[NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]]];
        if (_sel && [_sel isEqualToString:old]) {
            _sel = newName;
            NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
            [ud setObject:newName forKey:@"SelectedMaterialFolder"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LDDMatChanged" object:0];
        LDDNotifyMatChanged();
    } else {
        [self showTip:@"改名失败"];
    }
}
- (void)confirmDelete:(NSString *)name {
    UIAlertController *al = [UIAlertController alertControllerWithTitle:@"删除素材" message:[NSString stringWithFormat:@"确定删除「%@」? 不可恢复", name] preferredStyle:1];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"删除" style:2 handler:^(UIAlertAction *a){
        NSString *p = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:name];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm removeItemAtPath:p error:0]) {
            _folders = LDDListMaterialFolders();
            [_thumbs removeObjectForKey:name];
            [_anims removeObjectForKey:name];
            [(UICollectionView *)_cv reloadData];
            if (_editMode) [self startJiggling]; // 删除后保持编辑态抖动
            [self setBarTitle:[NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]]];
            if (_sel && [_sel isEqualToString:name]) {
                _sel = nil;
                NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
                [ud removeObjectForKey:@"SelectedMaterialFolder"];
            }
            LDDNotifyMatChanged();
        } else {
            [self showTip:@"删除失败"];
        }
    }];
    UIAlertAction *cc = [UIAlertAction actionWithTitle:@"取消" style:1 handler:0];
    [al addAction:yes];
    [al addAction:cc];
    [self presentViewController:al animated:YES completion:0];
}
- (void)showTip:(NSString *)msg {
    UIAlertController *al = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:1];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:0 handler:0];
    [al addAction:ok];
    [self presentViewController:al animated:YES completion:0];
}
- (void)importTapped {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"导入素材" message:@"选择来源" preferredStyle:0];
    UIAlertAction *a1 = [UIAlertAction actionWithTitle:@"从相册" style:0 handler:^(UIAlertAction *a){
        [self openPhotos];
    }];
    UIAlertAction *a2 = [UIAlertAction actionWithTitle:@"从文件" style:0 handler:^(UIAlertAction *a){
        [self openFiles];
    }];
    UIAlertAction *a3 = [UIAlertAction actionWithTitle:@"取消" style:1 handler:0];
    [sheet addAction:a1];
    [sheet addAction:a2];
    [sheet addAction:a3];
    [self presentViewController:sheet animated:YES completion:0];
}
- (void)openPhotos {
    UIImagePickerController *pc = [[UIImagePickerController alloc] init];
    [pc setSourceType:0];
    [pc setMediaTypes:[NSArray arrayWithObjects:@"public.image", @"public.movie", nil]];
    [pc setDelegate:self];
    [pc setAllowsEditing:NO];
    [self presentViewController:pc animated:YES completion:0];
}
- (void)openFiles {
    id utImage = ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("UTType"), sel_registerName("image"));
    id utMovie = ((id(*)(id, SEL))objc_msgSend)((id)objc_getClass("UTType"), sel_registerName("movie"));
    UIDocumentPickerViewController *dp = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:[NSArray arrayWithObjects:utImage, utMovie, nil]];
    [dp setDelegate:self];
    [self presentViewController:dp animated:YES completion:0];
}
// 相册回调
- (void)imagePickerController:(id)picker didFinishPickingMediaWithInfo:(id)info {
    LogB("PICK-DIDFINISH");
    @try {
        NSString *mt = [info objectForKeyedSubscript:@"UIImagePickerControllerMediaType"];
        _pendImg = [info objectForKeyedSubscript:@"UIImagePickerControllerOriginalImage"];
        _pendURL = [info objectForKeyedSubscript:@"UIImagePickerControllerMediaURL"];
        _pendVideo = mt && [mt isEqualToString:@"public.movie"];
        LogB(_pendImg ? "PICK-HAS-IMAGE" : "PICK-NO-IMAGE");
        [self dismissViewControllerAnimated:YES completion:0];
        [self performSelector:@selector(showNaming) withObject:0 afterDelay:0.5];
    } @catch (id e) { LogB("PICK-EXC"); }
}
- (void)notifyTapped {
    SEL sp = sel_registerName("showBannerPreview");
    SEL rs = sel_registerName("respondsToSelector:");
    id host = self;
    for (int i = 0; i < 5; i++) {
        if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(host, rs, sp)) break;
        id nx = ((id(*)(id, SEL))objc_msgSend)(host, sel_registerName("presentingViewController"));
        if (!nx) nx = ((id(*)(id, SEL))objc_msgSend)(host, sel_registerName("navigationController"));
        if (!nx || nx == host) break;
        host = nx;
    }
    if (((BOOL(*)(id, SEL, SEL))objc_msgSend)(host, rs, sp))
        ((void(*)(id, SEL))objc_msgSend)(host, sp);
}
- (void)showNaming {
    [self askNameAndSave:_pendImg url:_pendURL isVideo:_pendVideo];
}
- (void)imagePickerControllerDidCancel:(id)picker {
    [self dismissViewControllerAnimated:YES completion:0];
}
// 文件回调
- (void)documentPicker:(id)controller didPickDocumentsAtURLs:(id)urls {
    _pendImg = 0;
    _pendURL = [urls objectAtIndex:0];
    // 按扩展名识别视频 —— 旧逻辑恒 NO, 从"文件"导入的 mp4/mov 被存成 imported.jpg,
    // 素材加载当静态图解码失败 -> 岛上红块
    NSString *dpExt = [[_pendURL pathExtension] lowercaseString];
    _pendVideo = [dpExt isEqualToString:@"mp4"] || [dpExt isEqualToString:@"mov"] || [dpExt isEqualToString:@"m4v"];
    [self dismissViewControllerAnimated:YES completion:0];
    [self performSelector:@selector(showNaming) withObject:0 afterDelay:0.5];
}
- (void)documentPickerWasCancelled:(id)controller {
    [self dismissViewControllerAnimated:YES completion:0];
}
// 命名 + 保存
- (void)askNameAndSave:(id)img url:(id)srcURL isVideo:(BOOL)isVideo {
    LogB("ASKNAME");
    UIAlertController *al = [UIAlertController alertControllerWithTitle:@"命名素材" message:@"给这个素材起个名字" preferredStyle:1];
    [al addTextFieldWithConfigurationHandler:^(UITextField *tf){
        [tf setPlaceholder:@"素材名称"];
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"保存" style:0 handler:^(UIAlertAction *a){
        id tfs = [al textFields];
        UITextField *tf = [tfs objectAtIndex:0];
        NSString *nm = [tf text];
        if (!nm || [nm length] == 0) nm = @"新素材";
        [self saveMaterial:nm image:img url:srcURL isVideo:isVideo];
    }];
    UIAlertAction *cc = [UIAlertAction actionWithTitle:@"取消" style:1 handler:0];
    [al addAction:ok];
    [al addAction:cc];
    [self presentViewController:al animated:YES completion:0];
}
- (void)saveMaterial:(NSString *)nm image:(id)img url:(id)srcURL isVideo:(BOOL)isVideo {
    LogB("SAVE-START");
    @try {
    NSFileManager *fm = [NSFileManager defaultManager];
    // 素材名即目录名: 去掉路径分隔符与首尾空白, 防"名字带/"把目录建到子层级或越出素材根目录
    NSString *safe = [[nm componentsSeparatedByString:@"/"] componentsJoinedByString:@"-"];
    safe = [safe stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!safe || [safe length] == 0) safe = @"新素材";
    NSString *dir = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:safe];
    [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:0 error:0];
    BOOL ok = NO;
    if (img) {
        id data = UIImageJPEGRepresentation(img, 0.85);
        ok = [data writeToFile:[dir stringByAppendingPathComponent:@"imported.jpg"] atomically:YES];
    } else if (srcURL) {
        // 保留真实扩展名: 视频按来源(mp4/mov/m4v), 图片按来源(png/jpg/jpeg); 未知才用兜底
        NSString *srcExt = [[srcURL pathExtension] lowercaseString];
        NSString *ext;
        if (isVideo) {
            ext = ([srcExt isEqualToString:@"mp4"] || [srcExt isEqualToString:@"mov"] || [srcExt isEqualToString:@"m4v"]) ? srcExt : @"mov";
        } else {
            ext = ([srcExt isEqualToString:@"png"] || [srcExt isEqualToString:@"jpg"] || [srcExt isEqualToString:@"jpeg"]) ? srcExt : @"jpg";
        }
        // 文件选取器返回的是安全作用域 URL, 复制前先取得访问权(失败也能继续拷, 越狱环境下权限宽松)
        BOOL scoped = ((BOOL(*)(id, SEL))objc_msgSend)(srcURL, sel_registerName("startAccessingSecurityScopedResource"));
        ok = [fm copyItemAtURL:srcURL toURL:[NSURL fileURLWithPath:[dir stringByAppendingPathComponent:[NSString stringWithFormat:@"imported.%@", ext]]] error:0];
        if (scoped) ((void(*)(id, SEL))objc_msgSend)(srcURL, sel_registerName("stopAccessingSecurityScopedResource"));
    }
    LogB(ok ? "SAVE-OK" : "SAVE-FAIL");
    // 刷新列表
    _folders = LDDListMaterialFolders();
    NSString *cnt = [NSString stringWithFormat:@"素材库 (%lu)", (unsigned long)[_folders count]];
    [self setBarTitle:cnt];
    [(UICollectionView *)_cv reloadData];
    LogB("SAVE-RELOADED");
    (void)ok;
    } @catch (id e) { LogB("SAVE-EXC"); }
}
- (NSInteger)collectionView:(id)cv numberOfItemsInSection:(NSInteger)s {
    return _folders ? (NSInteger)[_folders count] : 0;
}
- (id)collectionView:(id)cv cellForItemAtIndexPath:(id)ip {
    NSInteger row = [ip row];
    UICollectionViewCell *cell = [(UICollectionView *)cv dequeueReusableCellWithReuseIdentifier:@"m" forIndexPath:ip];
    for (UIView *v in [[cell contentView] subviews]) { if (v) [v removeFromSuperview]; }
    if (!_folders || row >= (NSInteger)[_folders count]) return cell;
    NSString *name = [_folders objectAtIndex:(NSUInteger)row];
    // 1.9.195: item 宽 = 行宽/3, 卡片在 cell 内左右各缩 6pt (视觉 12pt 列距), 图片仍为方形
    double w = ([[UIScreen mainScreen] bounds].w - 32.0) / 3.0;
    double cardW = w - 12.0;
    double imgH = cardW;
    {
        // 1.63: 探针限流 —— 每次刷新 12 行 × N 轮刷屏
        static int mc = 0;
        if (mc < 24) {
            mc++;
            char bl[160];
            snprintf(bl, sizeof(bl), "MAT-CELL row=%ld w=%.2f cardW=%.2f", (long)row, w, cardW);
            PwB(bl);
        }
    }
    // 白色圆角卡片 + 图 (卡片不裁切, 让删除钮可盖住并伸出右上角; 图片圆角由 iv 自己裁切)
    UIView *card = [[UIView alloc] initWithFrame:MakeRect(6, 0, cardW, imgH)];
    [card setBackgroundColor:[UIColor whiteColor]];
    [card setTag:911];
    [[card layer] setCornerRadius:14.0];
    UIImage *thumb = [_thumbs objectForKeyedSubscript:name];
    NSString *typeTag = @"图片";
    BOOL hasVideo = NO;
    {
        NSString *full = [@"/var/mobile/lddgifbg" stringByAppendingPathComponent:name];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:full error:nil];
        for (NSString *f in files) {
            NSString *ext = [[f pathExtension] lowercaseString];
            if ([ext isEqualToString:@"gif"]) { typeTag = @"GIF"; if (!thumb) thumb = ThumbForPath([full stringByAppendingPathComponent:f]); break; }
            if ([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mov"]) { typeTag = @"视频"; hasVideo = YES; if (!thumb) thumb = ThumbForPath([full stringByAppendingPathComponent:f]); }
            if ([ext isEqualToString:@"png"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"]) { typeTag = @"图片"; if (!thumb) thumb = ThumbForPath([full stringByAppendingPathComponent:f]); }
        }
        if (thumb) [_thumbs setObject:thumb forKeyedSubscript:name];
    }
    UIImageView *iv = [[UIImageView alloc] initWithFrame:MakeRect(0, 0, cardW, imgH)];
    [iv setImage:thumb];
    [iv setContentMode:2];
    [[iv layer] setCornerRadius:14.0];
    [[iv layer] setMasksToBounds:YES];
    [card addSubview:iv];
    UILabel *badge = [[UILabel alloc] initWithFrame:MakeRect(6, 6, 34, 16)];
    [badge setText:typeTag];
    [badge setFont:[UIFont systemFontOfSize:9.0]];
    [badge setTextAlignment:1];
    [badge setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.55]];
    [badge setTextColor:[UIColor whiteColor]];
    [[badge layer] setCornerRadius:8.0];
    [[badge layer] setMasksToBounds:YES];
    [card addSubview:badge];
    // 1.9.191: 视频素材左下角播放标志(区分视频/图片)
    if (hasVideo) {
        UIView *vb = [[UIView alloc] initWithFrame:MakeRect(6, imgH - 30, 24, 24)];
        [vb setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.45]];
        [[vb layer] setCornerRadius:12.0];
        [[vb layer] setMasksToBounds:YES];
        UILabel *pl = [[UILabel alloc] initWithFrame:MakeRect(0, -1, 24, 24)];
        [pl setText:@"▶"];
        [pl setFont:[UIFont systemFontOfSize:11.0]];
        [pl setTextAlignment:1];
        [pl setTextColor:[UIColor whiteColor]];
        [vb addSubview:pl];
        [card addSubview:vb];
    }
    // 1.9.191: 编辑态删除钮(红底白"-", 圆心卡缩略图右上角: 一半盖图角一半伸出, 随卡片一起抖动)
    // 1.44: 换真 UIButton(UIControl 触控处理比"普通视图+点按手势"可靠, 抖动中也能稳定命中)
    // 并加大热区(26x26), 删除确认弹窗兜底防误触
    if (_editMode) {
        UIButton *delv = [[UIButton alloc] initWithFrame:MakeRect(cardW - 14, -12, 26, 26)];
        [delv setBackgroundColor:[UIColor redColor]];
        [[delv layer] setCornerRadius:13.0];
        [[delv layer] setMasksToBounds:YES];
        [delv setTitle:@"-" forState:0];
        [delv setTitleColor:[UIColor whiteColor] forState:0];
        [delv setFont:[UIFont boldSystemFontOfSize:19.0]];
        [delv addTarget:self action:@selector(delBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [card addSubview:delv];
        objc_setAssociatedObject(delv, &kLDDDelKey, name, 1); // OBJC_ASSOCIATION_RETAIN_NONATOMIC
        // 1.59: 下载到相册功能已按用户要求移除(系统限制: 静图方案丢 GIF 动图, 体验不佳)
    }
    [[cell contentView] addSubview:card];
    // 名字胶囊 (点按 -> 行内改名); 1.9.201: x=10 与卡片(x=6,宽cardW)水平居中对齐 —— 用户反馈胶囊偏左
    UIView *pill = [[UIView alloc] initWithFrame:MakeRect(10, imgH + 7, cardW - 8, 22)];
    [pill setBackgroundColor:[UIColor colorWithWhite:0.62 alpha:0.85]];
    [[pill layer] setCornerRadius:11.0];
    [[pill layer] setMasksToBounds:YES];
    UILabel *plb = [[UILabel alloc] initWithFrame:MakeRect(0, 0, cardW - 8, 22)];
    [plb setText:name];
    [plb setFont:[UIFont systemFontOfSize:11.0]];
    [plb setTextAlignment:1];
    [plb setTextColor:[UIColor whiteColor]];
    [plb setTag:922];
    [pill addSubview:plb];
    [[cell contentView] addSubview:pill];
    UITapGestureRecognizer *ng = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nameTapped:)];
    [pill addGestureRecognizer:ng];
    objc_setAssociatedObject(ng, &kLDDNameKey, name, 1);
    // 选中圆点 (编辑态隐藏)
    if (!_editMode) {
        BOOL on = _sel && [_sel isEqualToString:name];
        UIView *dot = [[UIView alloc] initWithFrame:MakeRect(6 + cardW / 2 - 9, imgH + 33, 18, 18)];
        [[dot layer] setCornerRadius:9.0];
        [[dot layer] setMasksToBounds:YES];
        [dot setBackgroundColor:(on ? [UIColor systemBlueColor] : [UIColor colorWithWhite:0.80 alpha:1.0])];
        [[cell contentView] addSubview:dot];
    }
    // 1.9.192: 编辑态直接给卡片加抖动(创建即抖, 不依赖 reloadData 后 visibleCells 时机)
    if (_editMode) [self jiggleCard:card];
    return cell;
}
- (void)collectionView:(id)cv didSelectItemAtIndexPath:(id)ip {
    if (_editMode) return; // 编辑态点选不生效(删除走删除钮, 退出走"完成")
    NSInteger row = [ip row];
    if (!_folders || row >= (NSInteger)[_folders count]) return;
    NSString *name = [_folders objectAtIndex:(NSUInteger)row];
    _sel = name;
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:name forKey:@"SelectedMaterialFolder"];
    [ud synchronize];
    WritePrefsFile(@"SelectedMaterialFolder", name);
    [(UICollectionView *)cv reloadData];
    // 1.9.144: 通知设置页刷新预览 (不依赖 viewWillAppear)
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LDDMatChanged" object:0];
    // 1.56: 点卡片切素材同样广播(旧版只写 prefs 不广播, SpringBoard 侧 2s 缓存不失效 -> 切了没反应)
    {
        const char *nc = ((const char *(*)(id, SEL))objc_msgSend)(name, sel_registerName("UTF8String"));
        char bl[192]; snprintf(bl, sizeof(bl), "MAT-SELECT %s", nc ? nc : "?");
        PwB(bl);
    }
    LDDNotifyMatChanged();
}
@end

// ---------- 设置主控制器: PSListController 子类 + 直接自绘 6 行 (无模态无延迟) ----------
@interface lddgifbgRootListController : PSListController
- (NSInteger)numberOfSectionsInTableView:(id)tv;
- (NSInteger)tableView:(id)tv numberOfRowsInSection:(NSInteger)s;
- (id)tableView:(id)tv cellForRowAtIndexPath:(id)ip;
- (void)tableView:(id)tv didSelectRowAtIndexPath:(id)ip;
// 1.9.153: 点击数值弹出输入框
- (void)valTapped:(UITapGestureRecognizer *)g;
- (void)footerCopyTapped:(UITapGestureRecognizer *)g;
- (void)footerCopyRestore:(NSTimer *)t;
// 1.64: 跳转素材目录的 Filza 兜底提示
- (void)showTip:(NSString *)msg;
// 1.68: 素材随机锚定弹层 + 滑条数值内联输入
- (void)openRandomPickerAtIndexPath:(id)ip tableView:(id)tv;
- (void)dismissRandomPicker;
- (void)randomOptTapped:(id)b;
- (void)inlineEditDone:(id)tf;
@end

// 1.68: 素材随机锚定弹层
static const char kLDDRandOptKey = 0;
// 1.86: 通知窗口样式选择手势的序号关联
static const char kLDDStyleKey = 0;
// 1.97: 好宽度缓存 (预览图已改固定尺寸, 仅标题/说明的宽度微调还引用它, 保留无害)
static double sGoodCellW = 0;

@implementation lddgifbgRootListController
// 1.72: 关闭随机弹层(弹层挂在窗口层, 从 keyWindow 找)
- (void)dismissRandomPicker {
    id win = [[UIApplication sharedApplication] keyWindow];
    if (!win) return;
    UIView *menu = [win viewWithTag:997];
    if (menu) [menu removeFromSuperview];
    UIView *mask = [win viewWithTag:996];
    if (mask) [mask removeFromSuperview];
    gRandLabel = nil;
}
// 1.72: 离开页面时清理窗口层弹层
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self dismissRandomPicker];
}
// 1.69: 弹层打开时记住值标签, 选中后刷新文字
static UILabel *gRandLabel = nil;
// 1.76: 选中一个随机模式(从 tap 手势关联对象取 mode)
- (void)randomOptTapped:(UITapGestureRecognizer *)g {
    NSNumber *k = objc_getAssociatedObject(g, &kLDDRandOptKey);
    long mode = k ? (long)[k doubleValue] : 0;
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithDouble:(double)mode] forKey:@"lddgifbgRandom"];
    [ud synchronize];
    WritePrefsFile(@"lddgifbgRandom", [NSNumber numberWithDouble:(double)mode]);
    // 1.69: 同步方框文字(1.68 漏了这步, 选完一直显示旧字)
    if (gRandLabel) {
        [gRandLabel setText:LDDRandomName(mode)];
        gRandLabel = nil;
    }
    [self dismissRandomPicker];
}
// 1.86: 通知窗口样式选择 (0标准 1紧凑 2迷你 3自定义) —— 自制通知卡片的样式预选, 先存档
- (void)styleTapped:(UITapGestureRecognizer *)g {
    NSNumber *k = objc_getAssociatedObject(g, &kLDDStyleKey);
    long st = k ? (long)[k doubleValue] : 0;
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithDouble:(double)st] forKey:@"lddgifbgNotifStyle"];
    [ud synchronize];
    WritePrefsFile(@"lddgifbgNotifStyle", [NSNumber numberWithDouble:(double)st]);
    id tb = [self table];
    if (tb) [tb reloadData];
}
// 1.72: 锚定弹层挂窗口层 —— 屏幕坐标定位, 永远紧贴方框下方, 不随表格滚动错位
// 菜单紧凑(行高 38), 选项文字居中带 ✓, 白卡片圆角+阴影, 淡入
- (void)openRandomPickerAtIndexPath:(id)ip tableView:(id)tv {
    [self dismissRandomPicker];
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    id v = [ud objectForKey:@"lddgifbgRandom"];
    long cur = v ? (long)[v doubleValue] : 0;
    id cell = [(UITableView *)tv cellForRowAtIndexPath:ip];
    if (cell) gRandLabel = (UILabel *)[cell viewWithTag:2029];
    UIView *box = [cell viewWithTag:2031];
    if (!box) return;
    // 方框在窗口(屏幕)坐标里的位置
    CGRect wb = [box convertRect:[box bounds] toView:nil];
    double mw = wb.w;
    double mx = wb.ox;
    double my = wb.oy + wb.h + 4.0;
    double mh = 5.0 * 38.0;
    // 挂到窗口层(屏幕坐标, 不随表格滚动)
    id win = [[UIApplication sharedApplication] keyWindow];
    if (!win) return;
    // 全屏半透明遮罩(点空白关闭)
    UIView *mask = [[UIView alloc] initWithFrame:[win bounds]];
    [mask setTag:996];
    [mask setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.12]];
    UITapGestureRecognizer *dg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissRandomPicker)];
    [mask addGestureRecognizer:dg];
    [win addSubview:mask];
    // 菜单本体: 白卡片圆角+阴影, 与方框同宽同位
    UIView *menu = [[UIView alloc] initWithFrame:MakeRect(mx, my, mw, mh)];
    [menu setTag:997];
    [menu setBackgroundColor:[UIColor whiteColor]];
    [[menu layer] setCornerRadius:14.0];
    [[menu layer] setMasksToBounds:YES];
    [[menu layer] setShadowColor:(CGColorRef)[[UIColor colorWithWhite:0.0 alpha:1.0] CGColor]];
    [[menu layer] setShadowOpacity:0.15];
    [[menu layer] setShadowRadius:10.0];
    CGSize so; so.w = 0.0; so.h = 5.0;
    [[menu layer] setShadowOffset:so];
    [menu setAlpha:0.0];
    [win addSubview:menu];
    for (int k = 0; k < 5; k++) {
        // 1.76: 选项行改为 UILabel(左对齐) + tap 手势, ✓ 固定左侧不推挤文字
        UIView *optRow = [[UIView alloc] initWithFrame:MakeRect(0, k * 38.0, mw, 38.0)];
        UITapGestureRecognizer *optTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(randomOptTapped:)];
        objc_setAssociatedObject(optTap, &kLDDRandOptKey, [NSNumber numberWithDouble:(double)k], 1);
        [optRow addGestureRecognizer:optTap];
        [optRow setBackgroundColor:[UIColor clearColor]];
        [menu addSubview:optRow];
        UILabel *ck = [[UILabel alloc] initWithFrame:MakeRect(8, 0, 16, 38)];
        [ck setText:(cur == k ? @"✓" : @"")];
        [ck setFont:[UIFont systemFontOfSize:13.0]];
        [ck setTextColor:[UIColor colorWithWhite:0.15 alpha:1.0]];
        [ck setTextAlignment:0];
        [optRow addSubview:ck];
        UILabel *tl = [[UILabel alloc] initWithFrame:MakeRect(28, 0, mw - 36, 38)];
        [tl setText:LDDRandomName(k)];
        [tl setFont:[UIFont systemFontOfSize:14.0]];
        [tl setTextColor:[UIColor colorWithWhite:0.15 alpha:1.0]];
        [tl setTextAlignment:0];
        [optRow addSubview:tl];
        if (k < 4) {
            UIView *sep = [[UIView alloc] initWithFrame:MakeRect(10, (k + 1) * 38.0 - 0.5, mw - 20, 0.5)];
            [sep setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
            [menu addSubview:sep];
        }
    }
    // 淡入
    [UIView animateWithDuration:0.15 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:0 animations:^{ [menu setAlpha:1.0]; } completion:0];
}
// 1.64: 根页面弹提示 (素材库页面的 showTip 是另一个类的, 这里需要自己的)
- (void)showTip:(NSString *)msg {
    @try {
        UIAlertController *al = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:1];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:0 handler:0];
        [al addAction:ok];
        [self presentViewController:al animated:YES completion:0];
    } @catch (id e) { LogB("ROOT-TIP-EXC"); }
}
- (void)showBannerPreview {
    @try {
        // 1.9.90: 只走文件通道(单通道)。此前双通道(文件+notify)在 SpringBoard 端
        // 因 main 队列串行+投递阻塞, 时间窗口去重失效 -> 每次点击弹两条/连点积压十几条。
        // 文件通道由布局 hook 消费(remove), 每次点击恰好触发一次投递。
        // 按钮 2s 连点去重 + 文件内容带时间戳 (SB 端按内容去重, 防残留双弹)
        // 1.9.126: 去掉按钮 1s 去重 —— 点多少下都立即写文件立即弹
        NSString *tsStr = [NSString stringWithFormat:@"%ld", (long)time(0)];
        id tsData = ((id(*)(id, SEL, NSUInteger))objc_msgSend)(tsStr, sel_registerName("dataUsingEncoding:"), (NSUInteger)4);
        [[NSFileManager defaultManager] createFileAtPath:@"/var/mobile/lddgifbg/__force_preview__" contents:tsData attributes:0];
        // 1.85: 通知即时触发消费 (主进程监听后立刻弹预览), 文件轮询降为 1s 兜底
        notify_post("com.tlzypjy.github/ForcePreview");
        return;
    } @catch (id e) {}
}
- (void)viewDidLoad {
    LogB("ROOT-VIEWDIDLOAD");
    @try { [super viewDidLoad]; } @catch (id e) { LogB("ROOT-VD-EXC"); }
    [self setTitle:@"灵动岛背景美化"];   // 1.17: 更名
    // 1.9.144: 素材切换通知 -> 强制刷新预览行
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(matChanged) name:@"LDDMatChanged" object:0];
}
// 1.9.144: 素材切换后刷新
- (void)matChanged {
    LogB("MAT-CHANGED-NOTIFY");
    id tb = [self table];
    if (tb) [tb reloadData];
}
// 1.9.140: 从素材选择器返回时刷新预览行 (跟随新素材)
// 1.78: 建行宽度已改为表格实际宽, 不再依赖布局时序, 刷新放回 viewWillAppear(转场前, 不可见)
- (void)viewWillAppear:(BOOL)animated {
    @try { [super viewWillAppear:animated]; } @catch (id e) { LogB("ROOT-WVA-EXC"); }
    id tb = [self table];
    if (tb) { [tb reloadData]; LogB("PREVIEW-RELOAD-OK"); }
    else LogB("PREVIEW-RELOAD-NO-TABLE");
}
- (id)specifiers {
    @try { return [self loadSpecifiersFromPlistName:@"Root" target:self]; }
    @catch (id e) { LogB("ROOT-SPEC-EXC"); }
    return [NSArray array];
}
// 1.87: 3 个分区 —— 0=原功能行 1=样式选择大卡(灰标题在分区头/缩略图/单选圈/自定义样式设置标题) 2=样式说明文字
- (NSInteger)numberOfSectionsInTableView:(id)tv { return 2; }
// 1.9.140: 行数 10 (0/1开关 2预览 3水平偏移 4垂直偏移 5速度 6选素材 7跳转 8预览通知 9注销)
// 1.9.184: 行数 10 (版本/作者 移除, 改底部居中版权 footer)
// 1.52 自用版: 行数 9 (0开关 1预览 2水平偏移 3垂直偏移 4速度 5选素材 6跳转 7预览通知 8注销)
// 1.50/1.51 的横幅样式/停留时长行已随崩溃钩子一并移除(见 main.mm 注释)
// 1.66: 行数 10 (0开关 1预览 2水平偏移 3垂直偏移 4速度 5素材随机 6选素材 7跳转 8预览通知 9注销)
- (NSInteger)tableView:(id)tv numberOfRowsInSection:(NSInteger)s { return s == 0 ? 10 : 1; }
// 1.66: 素材随机模式名 (0关 1全部随机 2不重复随机)
static NSString *LDDRandomName(long s) {
    if (s == 1) return @"顺序显示";
    if (s == 2) return @"随机显示";
    if (s == 3) return @"随机动图";
    if (s == 4) return @"随机视频";
    return @"固定显示";
}
// 1.9.156: 输入框预填值去小数 (偏移=整数, 速度=去尾零保留1位)
static NSString *LDDInputNum(double v, BOOL isSpeed) {
    if (!isSpeed) return [NSString stringWithFormat:@"%.0f", v];
    if (v == (double)(long long)v) return [NSString stringWithFormat:@"%.0f", v];
    return [NSString stringWithFormat:@"%.1f", v];
}
// 1.81: 小号滑块圆钮 (21pt 白底细灰边) —— 系统默认圆钮 ~28pt 太大; 只换圆钮不动轨道
static UIImage *LDDSliderThumbImg(void) {
    static UIImage *img = nil;
    if (img) return img;
    CGSize tsz; tsz.w = 21.0; tsz.h = 21.0;
    UIGraphicsBeginImageContextWithOptions(tsz, NO, 0.0);
    void *ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0.85, 0.85, 0.87, 1.0);
    CGContextFillEllipseInRect(ctx, MakeRect(0, 0, 21, 21));
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextFillEllipseInRect(ctx, MakeRect(1, 1, 19, 19));
    img = (UIImage *)UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
// 1.9.146: 预览尺寸, heightForRow/cellForRow 共用
// 1.55 自用版: 预览改为永久固定尺寸(撑满宽 x 固定高度) —— 不再跟随 __island_size__
// 上下跳动(旧逻辑高度取决于最近一次岛的形态, 音乐条/通知横幅来回切就变大变小)
// 1.56: 固定高度改 52 -> 1.57: 用户指定 65pt
static void LDDPreviewSize(double bw, double *piw, double *pih) {
    *piw = bw;
    *pih = 70.0;
}
- (double)tableView:(id)tv heightForRowAtIndexPath:(id)ip {
    // 1.87: 新分区行高 (1=样式选择大卡 214 / 2=说明文字 118)
    if ([ip section] == 1) return 214.0;
    if ([ip row] == 1) {
        // 1.9.146: 预览行高度贴合预览药丸, 消除上下大面积留白
        CGRect tb = [tv bounds];
        double bw = tb.w; if (bw < 100) bw = 390;
        double iw = 0, ih = 0;
        LDDPreviewSize(bw, &iw, &ih);
        return 14.0 + ih + 14.0;
    }
    return 52.0;
}
// 1.76: 预估值与实际高度完全一致 (预览行98/其余52), 消除进场时内容尺寸二次修正造成的整页抖动
- (double)tableView:(id)tv estimatedHeightForRowAtIndexPath:(id)ip {
    return [self tableView:tv heightForRowAtIndexPath:ip];
}
// 1.87: 分区头 —— 分区1 的灰标题在卡片外 (同灵动通知排版)
- (double)tableView:(id)tv estimatedHeightForHeaderInSection:(NSInteger)s { return s == 1 ? 30.0 : 0.0; }
- (double)tableView:(id)tv estimatedHeightForFooterInSection:(NSInteger)s { return 196.0; }
- (double)tableView:(id)tv heightForHeaderInSection:(NSInteger)s { return s == 1 ? 30.0 : 0.0; }
// 1.86: 页脚分区化 —— 仅最后一个分区(2)挂作者页脚, 其余分区用窄间距隔开
- (double)tableView:(id)tv heightForFooterInSection:(NSInteger)s { return s == 1 ? 196.0 : 6.0; }
// 1.1: 阻断 PSListController 私有 titleAlignmentForFooterInSection (内部 objectAtIndex 越界 → NSRangeException → 设置闪退)
- (NSInteger)tableView:(id)tv titleAlignmentForFooterInSection:(NSInteger)s { return 0; }
// 1.88: 同坑的分区头版 —— 新增分区后 PSListController 按分区号取头标题越界闪退, 覆盖阻断
- (NSInteger)tableView:(id)tv titleAlignmentForHeaderInSection:(NSInteger)s { return 0; }
// 1.87: 分区头视图 —— 灰色居中标题 (卡片外)
- (id)tableView:(id)tv viewForHeaderInSection:(NSInteger)s {
    if (s != 1) return nil;
    CGRect tb = ((CGRect(*)(id, SEL))objc_msgSend)(tv, sel_registerName("bounds"));
    double sw = tb.w;
    if (sw < 100) { CGRect sbb = [[UIScreen mainScreen] bounds]; sw = sbb.w; }
    UIView *hv = [[UIView alloc] initWithFrame:MakeRect(0, 0, sw, 30)];
    [hv setBackgroundColor:[UIColor clearColor]];
    UILabel *hl = [[UILabel alloc] initWithFrame:MakeRect(0, 4, sw, 22)];
    [hl setAutoresizingMask:2];
    [hl setText:@"灵动岛通知窗口样式选择"];
    [hl setTextColor:[UIColor colorWithWhite:0.45 alpha:1.0]];
    [hl setTextAlignment:1];
    [hl setFont:[UIFont systemFontOfSize:13.0]];
    [hv addSubview:hl];
    return hv;
}
// 1.9.185: 底部三行版权 footer (作者/版本号/越狱源), 越狱源点击复制
// 1.87: 仅分区 2 渲染作者页脚, 其余分区返回空(用 14pt 间距隔开各分区)
- (id)tableView:(id)tv viewForFooterInSection:(NSInteger)s {
    if (s != 1) return nil;
    // 1.4: 全宽 label + textAlignment 居中 (与容器宽度无关, 不会偏), 字号改小
    // 1.95: 四种样式说明并入本页脚 (不再单独开分区, 贴在样式卡下面), 作者信息接在其后
    CGRect tb = ((CGRect(*)(id, SEL))objc_msgSend)(tv, sel_registerName("bounds"));
    double sw = tb.w;
    if (sw < 100) { CGRect sbb = [[UIScreen mainScreen] bounds]; sw = sbb.w; }
    UIView *fv = [[UIView alloc] initWithFrame:MakeRect(0, 0, sw, 196)];
    UILabel *ds = [[UILabel alloc] initWithFrame:MakeRect(12, 0, sw - 24, 92)];
    [ds setNumberOfLines:0];
    [ds setText:@"四种样式:\n1.图标+时间+APP名称+标题+双行内容(不滚动显示)\n2.图标+时间+APP名称+标题+单行内容(滚动显示)\n3.图标+时间+APP名称+标题+内容(同行滚动显示)\n4.以标准样式为基础，自定义图标、时间、标题、APP名称、副标题和内容"];
    [ds setTextColor:[UIColor colorWithWhite:0.45 alpha:1.0]];
    [ds setTextAlignment:1];
    [ds setFont:[UIFont systemFontOfSize:12.0]];
    [ds setAutoresizingMask:2];
    [fv addSubview:ds];
    UILabel *l1 = [[UILabel alloc] initWithFrame:MakeRect(0, 104, sw, 20)];
    [l1 setText:@"作者：TL"];
    [l1 setFont:[UIFont systemFontOfSize:13.0]];
    [l1 setTextColor:[UIColor colorWithWhite:0.35 alpha:1.0]];
    [l1 setTextAlignment:1];
    [l1 setAutoresizingMask:98];
    [fv addSubview:l1];
    UILabel *l2 = [[UILabel alloc] initWithFrame:MakeRect(0, 130, sw, 18)];
    // 1.44: 版本号与 control 同步(Info.plist 为二进制无法随源码递增, 直接用常量, 发版改这里)
    NSString *ver = @"2.03";
    [l2 setText:[NSString stringWithFormat:@"版本号：%@", ver]];
    [l2 setFont:[UIFont systemFontOfSize:11.0]];
    [l2 setTextColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
    [l2 setTextAlignment:1];
    [l2 setAutoresizingMask:98];
    [fv addSubview:l2];
    UILabel *l3 = [[UILabel alloc] initWithFrame:MakeRect(0, 156, sw, 18)];
    [l3 setText:@"越狱源：https://tlzypjy.github.io/jb-repo/"];
    [l3 setFont:[UIFont systemFontOfSize:10.0]];
    [l3 setTextColor:[UIColor colorWithRed:0.0 green:0.45 blue:1.0 alpha:1.0]];
    [l3 setUserInteractionEnabled:YES];
    [l3 setTextAlignment:1];
    [l3 setAutoresizingMask:98];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerCopyTapped:)];
    [l3 addGestureRecognizer:tap];
    [fv addSubview:l3];
    return fv;
}
- (id)tableView:(id)tv titleForHeaderInSection:(NSInteger)s { return @""; }
- (id)tableView:(id)tv titleForFooterInSection:(NSInteger)s { return @""; }
- (id)tableView:(id)tv cellForRowAtIndexPath:(id)ip {
    NSInteger row = [ip row];
    NSInteger sec = [ip section];
    static int logged = 0;
    if (!logged) { logged = 1; LogB("ROOT-CELL-RENDERED"); }
    UITableView *table = (UITableView *)tv;
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"c"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:1 reuseIdentifier:@"c"];
    // 1.79 建行宽度: 优先用 cell 自身真实宽(复用池里的 cell 已按最终宽度布局过, 和 1.76/1.77 一致);
    // 新 cell 宽度无效时依次兜底表格宽/屏幕宽。1.78 直接取表格宽踩坑: 转场中表格处于过渡尺寸(比
    // 实际宽), 按它建行后 cell 不再变宽, 内容整体溢出屏幕右侧。
    // 伸缩的根治靠 autoresizing: cell 首次定宽/变宽时所有子视图自动跟随, 不再依赖刷新时机。
    double cbw = [[cell contentView] bounds].w;
    // 1.96: 复用 cell 的 content 宽度就是表格量好的真实宽, 路过即入缓存
    if (cbw >= 100.0) sGoodCellW = cbw;
    // 1.95: 优先用上次确认正确的宽度 (推入转场中 visibleCells 可能是空的, 靠它兜住)
    if (cbw < 100 && sGoodCellW > 100.0) cbw = sGoodCellW;
    if (cbw < 100) {
        // 1.94: 新 cell 首建时 content 尚无宽度 —— 借用屏幕上已布局 cell 的真实宽
        // (旧兜底用表格 bounds 是过渡值, 样式选择区每次刷新都按错宽重建导致右伸)
        id vis = ((id(*)(id, SEL))objc_msgSend)(table, sel_registerName("visibleCells"));
        if (vis) {
            for (id vc in vis) {
                if (!vc) continue;
                double vw = ((CGRect(*)(id, SEL))objc_msgSend)((id)[vc contentView], sel_registerName("bounds")).w;
                if (vw >= 100.0) { cbw = vw; sGoodCellW = vw; break; }
            }
        }
    }
    if (cbw < 100) cbw = [tv bounds].w;
    if (cbw < 100) cbw = [[UIScreen mainScreen] bounds].w;
    CGRect b = MakeRect(0, 0, cbw, 52);
    for (UIView *v in [[cell contentView] subviews]) { if (v) [v removeFromSuperview]; }
    [cell setSelectionStyle:0];
    [cell setAccessoryType:0];
    if (sec == 1) return cell;   // 1.98: content drawn in willDisplay (final width, same as mature tweaks)
    if (row == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 19, b.w - 110, 22)];
        [label setText:@"功能启用"];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [label setAutoresizingMask:4];
        [[cell contentView] addSubview:label];
        UISwitch *sw = [[UISwitch alloc] initWithFrame:MakeRect(b.w - 67, 11, 51, 31)];
        [sw setAutoresizingMask:1];
        [sw setTag:1001];
        NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id v = [ud objectForKey:@"Enablelddgifbg"];
        // 1.42: 仅剩总开关 —— 开=所有岛铺背景, 关=全部不铺(小岛开关已移除)
        BOOL on = v ? [v boolValue] : YES;
        [sw setOn:on animated:NO];
        [sw addTarget:self action:@selector(switchToggled:) forControlEvents:1 << 12];
        [[cell contentView] addSubview:sw];
    } else if (row == 1) {
        // 1.9.140: 实时预览 (黑底药丸模拟灵动岛 + 素材首帧 + 当前偏移)
        [cell setSelectionStyle:0];
        // 1.9.146: 尺寸统一走 LDDPreviewSize (岛比例 + 面板宽缩放)
        double iw = 0, ih = 0;
        LDDPreviewSize(b.w, &iw, &ih);
        CGRect cb = MakeRect((b.w - iw) / 2.0, 14, iw, ih);
        UIView *box = [[UIView alloc] initWithFrame:cb];
        [box setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
        [box setTag:2010];
        [box setAutoresizingMask:2];
        id blay = [box layer];
        [blay setCornerRadius:ih / 2.0];
        [blay setMasksToBounds:YES];
        [[cell contentView] addSubview:box];
        gPrevContainer = box;
        NSString *ppath = SelectedMaterialPathForPreview();
        UIImage *pimg = ppath ? ThumbForPath(ppath) : nil;
        if (pimg) {
            CGSize isz = [pimg size];
            double cw = cb.w, ch = cb.h;
            double sc = (cw / isz.w) > (ch / isz.h) ? (cw / isz.w) : (ch / isz.h);
            cw = isz.w * sc; ch = isz.h * sc;
            gPrevW = isz.w; gPrevH = isz.h;
            UIImageView *piv = [[UIImageView alloc] initWithFrame:MakeRect((cb.w - cw) / 2.0, (cb.h - ch) / 2.0, cw, ch)];
            [piv setContentMode:2];
            [piv setImage:pimg];
            [piv setTag:2011];
            [piv setAutoresizingMask:2];
            [box addSubview:piv];
            gPrevContent = piv;
        } else {
            gPrevW = 0; gPrevH = 0; gPrevContent = nil;
            UILabel *tip = [[UILabel alloc] initWithFrame:MakeRect(0, 0, cb.w, cb.h)];
            [tip setText:@"未选择素材"];
            [tip setTextColor:[UIColor whiteColor]];
            [tip setTextAlignment:1];
            [tip setFont:[UIFont systemFontOfSize:14.0]];
            [box addSubview:tip];
        }
        LDDUpdatePreview();
    } else if (row == 2) {
        // 1.9.140: 水平偏移 (左右调整显示区域, -200~200, 默认0)
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 15, 92, 22)];
        [label setText:@"水平偏移"];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [label setAutoresizingMask:4];
        [[cell contentView] addSubview:label];
        // 1.81: 滑条左移拉长, 左距标题 20 = 右距方框 20 等距(轨道内缩≈圆钮半径, 两侧对称抵消)
        UISlider *sl = [[UISlider alloc] initWithFrame:MakeRect(86, 12, b.w - 208, 28)];
        [sl setAutoresizingMask:2];
        [sl setThumbImage:LDDSliderThumbImg() forState:0];
        [sl setMinimumValue:-200];
        [sl setMaximumValue:200];
        NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id v = [ud objectForKey:@"lddgifbgPosX"];
        double dv = v ? [v doubleValue] : 0.0;
        [sl setValue:dv];
        [sl setTag:3003];   // 1.9.153: 自定义输入后同步滑块
        LogB("CELL-POSX-SLIDER");
        [sl addTarget:self action:@selector(posXChanged:) forControlEvents:(1 << 12) | (1 << 6) | (1 << 7)];
        [[cell contentView] addSubview:sl];
        // 1.80: 数值改同款方框(白底灰边圆角, 数字居中无箭头), 与显示模式方框同宽同位对齐; 点击仍可输入
        UIView *vb = [[UIView alloc] initWithFrame:MakeRect(b.w - 112, 11, 96, 30)];
        [vb setBackgroundColor:[UIColor whiteColor]];
        [[vb layer] setBorderWidth:0.5];
        [[vb layer] setBorderColor:(CGColorRef)[[UIColor colorWithWhite:0.78 alpha:1.0] CGColor]];
        [[vb layer] setCornerRadius:12.0];
        [[vb layer] setMasksToBounds:YES];
        [vb setAutoresizingMask:1];
        UILabel *vl = [[UILabel alloc] initWithFrame:MakeRect(0, 0, 96, 30)];
        [vl setTextAlignment:1];
        [vl setFont:[UIFont systemFontOfSize:14.0]];
        [vl setTextColor:[UIColor colorWithWhite:0.15 alpha:1.0]];
        [vl setTag:2023];
        [vl setText:[NSString stringWithFormat:@"%.0f", dv]];
        // 1.9.153: 点击数值可自定义输入
        [vl setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(valTapped:)];
        [vl addGestureRecognizer:tap];
        [vb addSubview:vl];
        [[cell contentView] addSubview:vb];
    } else if (row == 3) {
        // 1.9.140: 垂直偏移 (上下调整显示区域, -200~200, 默认0)
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 15, 92, 22)];
        [label setText:@"垂直偏移"];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [label setAutoresizingMask:4];
        [[cell contentView] addSubview:label];
        // 1.81: 滑条左移拉长, 左距标题 20 = 右距方框 20 等距(轨道内缩≈圆钮半径, 两侧对称抵消)
        UISlider *sl = [[UISlider alloc] initWithFrame:MakeRect(86, 12, b.w - 208, 28)];
        [sl setAutoresizingMask:2];
        [sl setThumbImage:LDDSliderThumbImg() forState:0];
        [sl setMinimumValue:-200];
        [sl setMaximumValue:200];
        NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id v = [ud objectForKey:@"lddgifbgPosY"];
        double dv = v ? [v doubleValue] : 0.0;
        [sl setValue:dv];
        [sl setTag:3004];   // 1.9.153
        LogB("CELL-POSY-SLIDER");
        [sl addTarget:self action:@selector(posYChanged:) forControlEvents:(1 << 12) | (1 << 6) | (1 << 7)];
        [[cell contentView] addSubview:sl];
        // 1.80: 数值方框 (同水平偏移行)
        UIView *vb = [[UIView alloc] initWithFrame:MakeRect(b.w - 112, 11, 96, 30)];
        [vb setBackgroundColor:[UIColor whiteColor]];
        [[vb layer] setBorderWidth:0.5];
        [[vb layer] setBorderColor:(CGColorRef)[[UIColor colorWithWhite:0.78 alpha:1.0] CGColor]];
        [[vb layer] setCornerRadius:12.0];
        [[vb layer] setMasksToBounds:YES];
        [vb setAutoresizingMask:1];
        UILabel *vl = [[UILabel alloc] initWithFrame:MakeRect(0, 0, 96, 30)];
        [vl setTextAlignment:1];
        [vl setFont:[UIFont systemFontOfSize:14.0]];
        [vl setTextColor:[UIColor colorWithWhite:0.15 alpha:1.0]];
        [vl setTag:2024];
        [vl setText:[NSString stringWithFormat:@"%.0f", dv]];
        // 1.9.153: 点击数值可自定义输入
        [vl setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(valTapped:)];
        [vl addGestureRecognizer:tap];
        [vb addSubview:vl];
        [[cell contentView] addSubview:vb];
    } else if (row == 4) {
        // 1.9.133: 播放速度滑块 (0.5x~2.0x)
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 15, 92, 22)];
        [label setText:@"播放速度"];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [label setAutoresizingMask:4];
        [[cell contentView] addSubview:label];
        // 1.81: 滑条左移拉长, 左距标题 20 = 右距方框 20 等距(轨道内缩≈圆钮半径, 两侧对称抵消)
        UISlider *sl = [[UISlider alloc] initWithFrame:MakeRect(86, 12, b.w - 208, 28)];
        [sl setAutoresizingMask:2];
        [sl setThumbImage:LDDSliderThumbImg() forState:0];
        [sl setMinimumValue:0.5];
        [sl setMaximumValue:3.0];   // 1.9.152: 支持到三倍速
        NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id v = [ud objectForKey:@"lddgifbgSpeed"];
        double dv = v ? [v doubleValue] : 1.0;
        if (dv <= 0) dv = 1.0;
        [sl setValue:dv];
        [sl setTag:3005];   // 1.9.153
        LogB("CELL-SPEED-SLIDER");
        [sl addTarget:self action:@selector(speedChanged:) forControlEvents:(1 << 12) | (1 << 6) | (1 << 7)];
        [[cell contentView] addSubview:sl];
        // 1.80: 数值方框 (同上; 1.80 速度不再带 x)
        UIView *vb = [[UIView alloc] initWithFrame:MakeRect(b.w - 112, 11, 96, 30)];
        [vb setBackgroundColor:[UIColor whiteColor]];
        [[vb layer] setBorderWidth:0.5];
        [[vb layer] setBorderColor:(CGColorRef)[[UIColor colorWithWhite:0.78 alpha:1.0] CGColor]];
        [[vb layer] setCornerRadius:12.0];
        [[vb layer] setMasksToBounds:YES];
        [vb setAutoresizingMask:1];
        UILabel *vl = [[UILabel alloc] initWithFrame:MakeRect(0, 0, 96, 30)];
        [vl setTextAlignment:1];
        [vl setFont:[UIFont systemFontOfSize:14.0]];
        [vl setTextColor:[UIColor colorWithWhite:0.15 alpha:1.0]];
        [vl setTag:2025];
        [vl setText:[NSString stringWithFormat:@"%.1f", dv]];
        // 1.9.153: 点击数值可自定义输入
        [vl setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(valTapped:)];
        [vl addGestureRecognizer:tap];
        [vb addSubview:vl];
        [[cell contentView] addSubview:vb];
    } else if (row == 5) {
        // 1.74: 显示模式
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 15, b.w - 130, 22)];
        [label setText:@"显示模式"];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [label setAutoresizingMask:4];
        [[cell contentView] addSubview:label];
        // 1.71: 方框样式(同灵动通知): 白底+灰边框+圆角, 文字左+橙色箭头右
        // 1.80: 收窄 110->96 并与三个数值方框同位对齐(x=b.w-112), 文字区缩到 68, 左边不再大片留白
        UIView *box = [[UIView alloc] initWithFrame:MakeRect(b.w - 112, 11, 96, 30)];
        [box setTag:2031];
        [box setBackgroundColor:[UIColor whiteColor]];
        [[box layer] setBorderWidth:0.5];
        [[box layer] setBorderColor:(CGColorRef)[[UIColor colorWithWhite:0.78 alpha:1.0] CGColor]];
        [[box layer] setCornerRadius:12.0];
        [[box layer] setMasksToBounds:YES];
        UILabel *vv = [[UILabel alloc] initWithFrame:MakeRect(0, 0, 68, 30)];
        [vv setFont:[UIFont systemFontOfSize:14.0]];
        [vv setTextColor:[UIColor colorWithWhite:0.15 alpha:1.0]];
        [vv setTextAlignment:1];
        [vv setTag:2029];
        NSUserDefaults *uds = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id sv = [uds objectForKey:@"lddgifbgRandom"];
        long st = sv ? (long)[sv doubleValue] : 0;
        [vv setText:LDDRandomName(st)];
        [box addSubview:vv];
        // 1.78: 箭头改 SF Symbol chevron.down (同灵动通知), 比原文字箭头大一圈
        UIImage *chImg = [UIImage systemImageNamed:@"chevron.down" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:16.0 weight:0.6]];
        if (chImg) {
            UIImageView *cv = [[UIImageView alloc] initWithFrame:MakeRect(68, 7, 22, 16)];
            [cv setImage:chImg];
            [cv setTintColor:[UIColor colorWithRed:1.0 green:0.58 blue:0.0 alpha:1.0]];
            [cv setContentMode:1];
            [box addSubview:cv];
        } else {
            UILabel *cv = [[UILabel alloc] initWithFrame:MakeRect(13, -4, 42, 30)];
            [cv setText:@"⌄"];
            [cv setFont:[UIFont boldSystemFontOfSize:20.0]];
            [cv setTextColor:[UIColor colorWithRed:1.0 green:0.58 blue:0.0 alpha:1.0]];
            [cv setTextAlignment:1];
            [box addSubview:cv];
        }
        [box setAutoresizingMask:1];
        [[cell contentView] addSubview:box];
        [cell setSelectionStyle:1];
    } else {
        NSString *t = (row == 6 ? @"选择素材" : (row == 7 ? @"素材目录" : (row == 8 ? @"预览通知" : @"立即注销")));
        UILabel *label = [[UILabel alloc] initWithFrame:MakeRect(16, 15, b.w - 60, 22)];
        [label setText:t];
        [label setFont:[UIFont systemFontOfSize:15.0]];
        [label setAutoresizingMask:4];
        if (row == 9) [label setTextColor:[UIColor redColor]];
        [[cell contentView] addSubview:label];
        [cell setSelectionStyle:1];
    }
    return cell;
}
// 1.98: style selector content drawn in willDisplay - cell already sized to final width here,
// width-timing races are gone at the root (this is how mature tweaks like DN avoid stretching)
- (void)tableView:(id)tv willDisplayCell:(id)cell forRowAtIndexPath:(id)ip {
    if ([ip section] != 1) return;
    @try {
        // 1.87: 复刻灵动通知排版 —— 灰标题在分区头(卡片外); 大白卡: 缩略图(黑描边)+名字+单选圈+间隔+自定义样式设置标题
        [cell setSelectionStyle:0];
        // 1.90: 去掉白卡片 —— 内容直接坐在页面背景上 (同灵动通知, 消除两层背景感)
        double cw = [[cell contentView] bounds].w;
        if (cw < 100) cw = sGoodCellW;
        if (cw < 100) return;
        CGRect b = MakeRect(0, 0, cw, 214);
        // 1.97: 缩略图改固定尺寸 —— 与建行宽度彻底脱钩, 首建拿到过渡宽度也不会再伸缩
        double tw = 68.0;
        double thh = 66.0;
        NSUserDefaults *ud2 = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
        id sv2 = [ud2 objectForKey:@"lddgifbgNotifStyle"];
        long cur = sv2 ? (long)[sv2 doubleValue] : 0;
        for (int i = 0; i < 4; i++) {
            double total = 4.0 * tw + 18.0;
            double cx = (cw - total) / 2.0 + i * (tw + 6.0);
            if (cx < 2.0) cx = 2.0;
            UIView *col = [[UIView alloc] initWithFrame:MakeRect(cx, 7, tw, 118)];
            // 1.93: 防右伸 —— 首建宽度若是过渡值, cell 定宽时按比例自动摊开
            [col setAutoresizingMask:5];
            [col setTag:4000];
            [col setUserInteractionEnabled:YES];
            UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(styleTapped:)];
            objc_setAssociatedObject(tg, &kLDDStyleKey, [NSNumber numberWithDouble:(double)i], 1);
            [col addGestureRecognizer:tg];
            [[cell contentView] addSubview:col];
            // 缩略图: 浅绿底 + 绿色圆(壁纸示意) + 黑描边 (同灵动通知)
            UIView *th = [[UIView alloc] initWithFrame:MakeRect(0, 0, tw, thh)];
            // 1.89: 缩略图透明底 (避免白卡上再叠一层底色的双层背景感), 只留黑描边+绿圆+药丸
            [th setBackgroundColor:[UIColor clearColor]];
            [[th layer] setCornerRadius:12.0];
            [[th layer] setBorderWidth:2.0];
            [[th layer] setBorderColor:(CGColorRef)[[UIColor colorWithWhite:0.12 alpha:1.0] CGColor]];
            [th setClipsToBounds:YES];
            [col addSubview:th];
            UIView *blob = [[UIView alloc] initWithFrame:MakeRect((tw - 56.0) / 2.0, thh - 28.0, 56, 56)];
            [blob setBackgroundColor:[UIColor colorWithRed:0.60 green:0.78 blue:0.52 alpha:1.0]];
            [[blob layer] setCornerRadius:28.0];
            [th addSubview:blob];
            // 岛形药丸 (四种样式不同大小, 宽度随缩略图自适应)
            UIView *pill = [[UIView alloc] initWithFrame:(i == 0 ? MakeRect(3, 3, tw - 6, 20) : (i == 1 ? MakeRect(7, 3, tw - 14, 17) : (i == 2 ? MakeRect(12, 3, tw - 24, 15) : MakeRect(16, 3, tw - 44, 12))))];
            [pill setBackgroundColor:[UIColor colorWithWhite:0.07 alpha:1.0]];
            CGRect pfr = [pill frame];
            [[pill layer] setCornerRadius:pfr.h / 2.0];
            [th addSubview:pill];
            if (i == 0) {
                UIView *ic = [[UIView alloc] initWithFrame:MakeRect(4, 3, 14, 14)];
                [ic setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
                [[ic layer] setCornerRadius:4.0];
                [pill addSubview:ic];
                UIView *l1 = [[UIView alloc] initWithFrame:MakeRect(22, 5, pfr.w - 28, 4)];
                [l1 setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.9]];
                [[l1 layer] setCornerRadius:2.0];
                [pill addSubview:l1];
                UIView *l2 = [[UIView alloc] initWithFrame:MakeRect(22, 12, pfr.w - 34, 4)];
                [l2 setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
                [[l2 layer] setCornerRadius:2.0];
                [pill addSubview:l2];
            } else if (i == 1) {
                UIView *ic = [[UIView alloc] initWithFrame:MakeRect(3, 2, 13, 13)];
                [ic setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
                [[ic layer] setCornerRadius:3.0];
                [pill addSubview:ic];
                UIView *l1 = [[UIView alloc] initWithFrame:MakeRect(19, 6, pfr.w - 25, 4)];
                [l1 setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.9]];
                [[l1 layer] setCornerRadius:2.0];
                [pill addSubview:l1];
            } else if (i == 2) {
                UIView *ic = [[UIView alloc] initWithFrame:MakeRect(2, 2, 11, 11)];
                [ic setBackgroundColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
                [[ic layer] setCornerRadius:3.0];
                [pill addSubview:ic];
                UIView *l1 = [[UIView alloc] initWithFrame:MakeRect(16, 5, pfr.w - 22, 4)];
                [l1 setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.9]];
                [[l1 layer] setCornerRadius:2.0];
                [pill addSubview:l1];
            } else {
                UIView *l1 = [[UIView alloc] initWithFrame:MakeRect(4, 4, pfr.w - 8, 4)];
                [l1 setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.9]];
                [[l1 layer] setCornerRadius:2.0];
                [pill addSubview:l1];
                // 自定义: 右侧小圆点 (同灵动通知)
                UIView *dot = [[UIView alloc] initWithFrame:MakeRect(tw - 28, 4, 9, 9)];
                [dot setBackgroundColor:[UIColor colorWithWhite:0.55 alpha:1.0]];
                [[dot layer] setCornerRadius:4.5];
                [th addSubview:dot];
            }
            // 名字
            UILabel *nm = [[UILabel alloc] initWithFrame:MakeRect(0, thh + 6, tw, 16)];
            [nm setText:(i == 0 ? @"标准" : (i == 1 ? @"紧凑" : (i == 2 ? @"迷你" : @"自定义")))];
            [nm setTextAlignment:1];
            [nm setFont:[UIFont boldSystemFontOfSize:13.0]];
            [col addSubview:nm];
            // 单选圈 (选中=蓝底白勾, 未选=白底蓝圈)
            UIView *rd = [[UIView alloc] initWithFrame:MakeRect((tw - 22.0) / 2.0, thh + 28, 22, 22)];
            [[rd layer] setCornerRadius:11.0];
            if (cur == i) {
                [rd setBackgroundColor:[UIColor colorWithRed:0.0 green:0.47 blue:1.0 alpha:1.0]];
                UILabel *ck = [[UILabel alloc] initWithFrame:MakeRect(0, 0, 22, 22)];
                [ck setText:@"✓"];
                [ck setTextColor:[UIColor whiteColor]];
                [ck setTextAlignment:1];
                [ck setFont:[UIFont boldSystemFontOfSize:14.0]];
                [rd addSubview:ck];
            } else {
                [rd setBackgroundColor:[UIColor whiteColor]];
                [[rd layer] setBorderWidth:1.5];
                [[rd layer] setBorderColor:(CGColorRef)[[UIColor colorWithRed:0.0 green:0.47 blue:1.0 alpha:1.0] CGColor]];
            }
            [col addSubview:rd];
        }
        // 1.90: 自定义样式设置标题 (页面直排, 同灵动通知)
        UILabel *tt = [[UILabel alloc] initWithFrame:MakeRect(16, 166, b.w - 32, 24)];
        [tt setAutoresizingMask:2];
        [tt setText:@"自定义样式设置"];
        [tt setFont:[UIFont boldSystemFontOfSize:17.0]];
        [[cell contentView] addSubview:tt];
    } @catch (id e) { }
}
- (void)tableView:(id)tv didSelectRowAtIndexPath:(id)ip {
    NSInteger row = [ip row];
    NSInteger sec = [ip section];
    [(UITableView *)tv deselectRowAtIndexPath:ip animated:YES];
    // 1.68: 内联输入框开着时, 先提交再消费本次点击
    UIView *rootV = [self view];
    UITextField *pend = (UITextField *)[rootV viewWithTag:7777];
    if (pend) { [self inlineEditDone:pend]; return; }
    // 1.86: 新分区 (样式选择/自定义设置/说明) 行点击不做事 —— 样式选择走缩略图手势
    if (sec != 0) return;
    // 1.66: 行号与 UI 同步 (0开关 1预览 2水平偏移 3垂直偏移 4速度 5素材随机 6选素材 7跳转 8预览通知 9注销)
    if (row == 5) {
        // 1.68: 锚定弹层选择随机模式(同灵动通知"点击动作"交互)
        [self openRandomPickerAtIndexPath:ip tableView:tv];
    } else if (row == 6) {
        // 1.48: 素材库改为推入式第二设置页(从右滑入, 系统 nav bar 原生返回), 不再用底部弹出 sheet;
        // 无导航栈时回退模态呈现。
        LDDMaterialPickerController *pc = [[LDDMaterialPickerController alloc] init];
        UINavigationController *nc = [self navigationController];
        if (nc && [[nc viewControllers] count] > 0) {
            [nc pushViewController:pc animated:YES];
        } else {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pc];
            [self presentViewController:nav animated:YES completion:0];
        }
    } else if (row == 7) {
        // 1.64: 没装 Filza 时旧版静默无反应 -> 现在把路径复制到剪贴板并提示
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *fz = [NSURL URLWithString:@"filza://view/var/mobile/lddgifbg"];
        [app openURL:fz options:[NSDictionary dictionary] completionHandler:^(BOOL ok){
            if (!ok) {
                [[UIPasteboard generalPasteboard] setString:@"/var/mobile/lddgifbg"];
                [self showTip:@"未找到 Filza，素材目录路径已复制"];
            }
        }];
    } else if (row == 8) {
        [self showBannerPreview];
    } else if (row == 9) {
        [self respringNow];
    }
}
- (void)switchToggled:(UISwitch *)sw {
    NSString *key = @"Enablelddgifbg";
    BOOL on = [sw isOn];
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithBool:on] forKey:key];
    [ud synchronize];
    WritePrefsFile(key, [NSNumber numberWithBool:on]);
}
- (void)posXChanged:(UISlider *)sl {
    double dv = [sl value];
    { char bl[96]; snprintf(bl, sizeof(bl), "POSX-CHANGED %.2f", dv); LogB(bl); }
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithDouble:dv] forKey:@"lddgifbgPosX"];
    // 1.85: 拖动写盘节流 —— 文件+synchronize 最多 0.25s 一次(原每帧最高60次/s), 尾值 0.35s 后补写
    static double sLastWrX = 0; static int sFlushX = 0;
    double nwX = CFAbsoluteTimeGetCurrent();
    if (nwX - sLastWrX >= 0.25) {
        sLastWrX = nwX;
        [ud synchronize];
        WritePrefsFile(@"lddgifbgPosX", [NSNumber numberWithDouble:dv]);
    } else if (!sFlushX) {
        sFlushX = 1;
        dispatch_after(dispatch_time(0, 350 * 1000000LL), &_dispatch_main_q, ^{
            NSUserDefaults *ud2 = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
            id curX = [ud2 objectForKey:@"lddgifbgPosX"];
            if (curX) { [ud2 synchronize]; WritePrefsFile(@"lddgifbgPosX", curX); }
            sLastWrX = CFAbsoluteTimeGetCurrent();
            sFlushX = 0;
        });
    }
    { id rv = [ud objectForKey:@"lddgifbgPosX"]; double rd = rv ? [rv doubleValue] : -1.0; char bl[96]; snprintf(bl, sizeof(bl), "WRITE-POSX-OK %.2f", rd); LogB(bl); }
    // 1.9.152: 更新右侧数值显示
    id cv = [sl superview];
    if (cv) { UILabel *vl = (UILabel *)[cv viewWithTag:2023]; if (vl) [vl setText:[NSString stringWithFormat:@"%.0f", dv]]; }
    // 1.9.140: 实时刷新预览位置
    LDDUpdatePreview();
}
- (void)posYChanged:(UISlider *)sl {
    double dv = [sl value];
    { char bl[96]; snprintf(bl, sizeof(bl), "POSY-CHANGED %.2f", dv); LogB(bl); }
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithDouble:dv] forKey:@"lddgifbgPosY"];
    // 1.85: 拖动写盘节流 (同水平偏移)
    static double sLastWrY = 0; static int sFlushY = 0;
    double nwY = CFAbsoluteTimeGetCurrent();
    if (nwY - sLastWrY >= 0.25) {
        sLastWrY = nwY;
        [ud synchronize];
        WritePrefsFile(@"lddgifbgPosY", [NSNumber numberWithDouble:dv]);
    } else if (!sFlushY) {
        sFlushY = 1;
        dispatch_after(dispatch_time(0, 350 * 1000000LL), &_dispatch_main_q, ^{
            NSUserDefaults *ud2 = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
            id curY = [ud2 objectForKey:@"lddgifbgPosY"];
            if (curY) { [ud2 synchronize]; WritePrefsFile(@"lddgifbgPosY", curY); }
            sLastWrY = CFAbsoluteTimeGetCurrent();
            sFlushY = 0;
        });
    }
    { id rv = [ud objectForKey:@"lddgifbgPosY"]; double rd = rv ? [rv doubleValue] : -1.0; char bl[96]; snprintf(bl, sizeof(bl), "WRITE-POSY-OK %.2f", rd); LogB(bl); }
    // 1.9.152: 更新右侧数值显示
    id cv = [sl superview];
    if (cv) { UILabel *vl = (UILabel *)[cv viewWithTag:2024]; if (vl) [vl setText:[NSString stringWithFormat:@"%.0f", dv]]; }
    // 1.9.140: 实时刷新预览位置
    LDDUpdatePreview();
}
- (void)speedChanged:(UISlider *)sl {
    double dv = [sl value];
    { char bl[96]; snprintf(bl, sizeof(bl), "SPEED-CHANGED %.2f", dv); LogB(bl); }
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    [ud setObject:[NSNumber numberWithDouble:dv] forKey:@"lddgifbgSpeed"];
    // 1.85: 拖动写盘节流 (同水平偏移)
    static double sLastWrS = 0; static int sFlushS = 0;
    double nwS = CFAbsoluteTimeGetCurrent();
    if (nwS - sLastWrS >= 0.25) {
        sLastWrS = nwS;
        [ud synchronize];
        WritePrefsFile(@"lddgifbgSpeed", [NSNumber numberWithDouble:dv]);
    } else if (!sFlushS) {
        sFlushS = 1;
        dispatch_after(dispatch_time(0, 350 * 1000000LL), &_dispatch_main_q, ^{
            NSUserDefaults *ud2 = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
            id curS = [ud2 objectForKey:@"lddgifbgSpeed"];
            if (curS) { [ud2 synchronize]; WritePrefsFile(@"lddgifbgSpeed", curS); }
            sLastWrS = CFAbsoluteTimeGetCurrent();
            sFlushS = 0;
        });
    }
    // 1.9.137: 写后回读验证
    { id rv = [ud objectForKey:@"lddgifbgSpeed"]; double rd = rv ? [rv doubleValue] : -1.0; char bl[96]; snprintf(bl, sizeof(bl), "WRITE-SPEED-OK %.2f", rd); LogB(bl); }
    // 1.9.152: 更新右侧数值显示
    id cv = [sl superview];
    if (cv) { UILabel *vl = (UILabel *)[cv viewWithTag:2025]; if (vl) [vl setText:[NSString stringWithFormat:@"%.1f", dv]]; }
}
// 1.52 自用版: 横幅停留/样式滑条已随钩子回滚一并移除
// 1.68: 点击数值 -> 原位内联输入(同素材库改名交互), 不再弹 Alert
static UISlider *gEditSlider = nil;
static UILabel *gEditLabel = nil;
static NSString *gEditKey = nil;
static NSInteger gEditTag = 0;
static const char kLDDValTagKey = 0;
- (void)valTapped:(UITapGestureRecognizer *)g {
    id vl = [g view];
    NSInteger tag = [vl tag];
    if (tag != 2023 && tag != 2024 && tag != 2025) return;
    UIView *root = [self view];
    UITextField *old = (UITextField *)[root viewWithTag:7777];
    if (old) [old removeFromSuperview];
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
    NSString *key = (tag == 2023 ? @"lddgifbgPosX" : (tag == 2024 ? @"lddgifbgPosY" : @"lddgifbgSpeed"));
    id curV = [ud objectForKey:key];
    double dv = curV ? [curV doubleValue] : 0.0;
    gEditTag = tag; gEditKey = key;
    // 1.80: 数值标签现在嵌在方框里, superview 是方框找不到滑条, 改从根视图按唯一 tag 找
    gEditSlider = (UISlider *)[root viewWithTag:(tag == 2023 ? 3003 : (tag == 2024 ? 3004 : 3005))];
    gEditLabel = (UILabel *)vl;
    CGRect rf = [root convertRect:[vl frame] fromView:[vl superview]];
    if (rf.oy < 8) rf.oy = 8;
    // 1.69: 不扩宽不左移 —— 完全贴数值原位, 避免盖住滑条; 1.80 贴方框位, 文字居中与框一致
    UITextField *tf = [[UITextField alloc] initWithFrame:rf];
    [tf setText:(tag == 2025 ? LDDInputNum(dv, 1) : LDDInputNum(dv, 0))];
    [tf setTextAlignment:1];
    [tf setFont:[UIFont systemFontOfSize:14.0]];
    [tf setBorderStyle:3];     // 圆角边框, 与素材库改名一致
    [tf setKeyboardType:0];    // 默认键盘(带完成键)
    [tf setReturnKeyType:9];
    [tf setTag:7777];
    [tf addTarget:self action:@selector(inlineEditDone:) forControlEvents:(1 << 18) | (1 << 19)]; // EditingDidEndOnExit(按完成)
    objc_setAssociatedObject(tf, &kLDDValTagKey, [NSNumber numberWithDouble:(double)tag], 1);
    [root addSubview:tf];
    [tf becomeFirstResponder];
}
// 1.68: 内联输入提交(按完成或点其它行) —— 校验/入库/同步滑块和数值
- (void)inlineEditDone:(UITextField *)tf {
    @try {
        double nv = [[tf text] doubleValue];
        if (gEditTag == 2025) {
            if (nv < 0.5) nv = 0.5;
            if (nv > 3.0) nv = 3.0;
        } else {
            if (nv < -200) nv = -200;
            if (nv > 200) nv = 200;
        }
        if (gEditKey) {
            NSUserDefaults *ud2 = [[NSUserDefaults alloc] initWithSuiteName:@"lddgifbg"];
            [ud2 setObject:[NSNumber numberWithDouble:nv] forKey:gEditKey];
            [ud2 synchronize];
            WritePrefsFile(gEditKey, [NSNumber numberWithDouble:nv]);
        }
        if (gEditSlider) [gEditSlider setValue:nv];
        if (gEditLabel) {
            if (gEditTag == 2025) [gEditLabel setText:[NSString stringWithFormat:@"%.1f", nv]];
            else [gEditLabel setText:[NSString stringWithFormat:@"%.0f", nv]];
        }
        if (gEditTag == 2023 || gEditTag == 2024) LDDUpdatePreview();
    } @catch (id e) { LogB("INLINE-EXC"); }
    [tf removeFromSuperview];
    gEditSlider = nil; gEditLabel = nil; gEditKey = nil; gEditTag = 0;
}
- (void)testNotification {
    PostTestNotification();
}
- (void)respringNow {
    // 1.65: 改用 PATH 解析的 killall(二进制里不再出现 /var/jb 绝对路径,
    // RootHide 转换器的 fixed-paths 提示随之减少)
    @try {
        if (!_system_fn) {
            void *h = dlopen(0, 1);
            if (h) _system_fn = (int (*)(const char *))dlsym(h, "system");
        }
        if (_system_fn) _system_fn("killall -9 SpringBoard");
        else LogB("RESPRING-NO-SYS");
    } @catch (id e) { LogB("RESPRING-EXC"); }
}
// 1.9.185: 点击越狱源 -> 复制链接到剪贴板, 文字短暂反馈"已复制"
- (void)footerCopyTapped:(UITapGestureRecognizer *)g {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:@"https://tlzypjy.github.io/jb-repo/"];
    UILabel *l3 = (UILabel *)[g view];
    if (l3) {
        [l3 setText:@"越狱源已复制 ✓"];
        [l3 setTextColor:[UIColor colorWithRed:0.1 green:0.7 blue:0.2 alpha:1.0]];
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(footerCopyRestore:) userInfo:l3 repeats:NO];
    }
}
- (void)footerCopyRestore:(NSTimer *)t {
    UILabel *l3 = (UILabel *)[t userInfo];
    if (l3) {
        [l3 setText:@"越狱源：https://tlzypjy.github.io/jb-repo/"];
        [l3 setTextColor:[UIColor colorWithRed:0.0 green:0.45 blue:1.0 alpha:1.0]];
    }
}
@end
