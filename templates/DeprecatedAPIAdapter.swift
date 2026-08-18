//
//  DeprecatedAPIAdapter.swift
//  Presentation
//
//  Created by Nguyen Chi Hieu on 25/2/26.
//

import UIKit
import VNPayInbox

// MARK: - ═══════════════════════════════════════════════════════════════
// MARK:   1. UIScreen (deprecated iOS 26.0)
// MARK: ═══════════════════════════════════════════════════════════════
//
//  FIND & REPLACE:
//    UIScreen.main.bounds       → UIScreen.safeMain.bounds
//    UIScreen.main.scale        → UIScreen.safeMain.scale
//    UIScreen.main.nativeScale  → UIScreen.safeMain.nativeScale
//    UIScreen.main.maximumFramesPerSecond → UIScreen.safeMain.maximumFramesPerSecond
//

extension UIScreen {

    /// Safe replacement for `UIScreen.main` that works on iOS 26+
    @objc static var safeMain: UIScreen {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first
        return scene?.screen ?? UIScreen.main
    }
}

// MARK: - ═══════════════════════════════════════════════════════════════
// MARK:   2. UIWindow (deprecated iOS 26.0)
// MARK: ═══════════════════════════════════════════════════════════════
//
//  FIND & REPLACE:
//    UIWindow(frame: UIScreen.main.bounds) → UIWindow.safeCreate()
//    UIWindow(frame: ...)                  → UIWindow.safeCreate(windowScene:)
//

extension UIWindow {

    /// Safe replacement for `UIWindow(frame:)`
    @objc static func safeCreate(windowScene: UIWindowScene? = nil) -> UIWindow {
        if let scene = windowScene {
            return UIWindow(windowScene: scene)
        }
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first {
            return UIWindow(windowScene: scene)
        }
        return UIWindow(frame: UIScreen.safeMain.bounds)
    }
}

// MARK: - ═══════════════════════════════════════════════════════════════
// MARK:   3. UIBarButtonItem.Style (deprecated iOS 26.0)
// MARK: ═══════════════════════════════════════════════════════════════
//
//  FIND & REPLACE:
//    .done → .safeDone
//

extension UIBarButtonItem.Style {

    /// Safe replacement for `.done` → `.prominent` on iOS 26+
    static var safeDone: UIBarButtonItem.Style {
        if #available(iOS 26.0, *) {
            return .prominent
        }
        return .done
    }
}

// MARK: - ═══════════════════════════════════════════════════════════════
// MARK:   4. UINavigationBarAppearance (deprecated iOS 26.0)
// MARK: ═══════════════════════════════════════════════════════════════
//
//  FIND & REPLACE:
//    appearance.doneButtonAppearance → appearance.safeDoneButtonAppearance
//

extension UINavigationBarAppearance {

    /// Safe replacement for `doneButtonAppearance`
    @objc var safeDoneButtonAppearance: UIBarButtonItemAppearance {
        get {
            if #available(iOS 26.0, *) {
                return prominentButtonAppearance
            }
            return doneButtonAppearance
        }
        set {
            if #available(iOS 26.0, *) {
                prominentButtonAppearance = newValue
            } else {
                doneButtonAppearance = newValue
            }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════════
// MARK:   5. UIToolbarAppearance (deprecated iOS 26.0)
// MARK: ═══════════════════════════════════════════════════════════════

extension UIToolbarAppearance {

    /// Safe replacement for `doneButtonAppearance`
    @objc var safeDoneButtonAppearance: UIBarButtonItemAppearance {
        get {
            if #available(iOS 26.0, *) {
                return prominentButtonAppearance
            }
            return doneButtonAppearance
        }
        set {
            if #available(iOS 26.0, *) {
                prominentButtonAppearance = newValue
            } else {
                doneButtonAppearance = newValue
            }
        }
    }
}

// MARK: - ═══════════════════════════════════════════════════════════════
// MARK:   6. UIApplication Key Window Helper (deprecated iOS 13+)
// MARK: ═══════════════════════════════════════════════════════════════
//
//  FIND & REPLACE:
//    UIApplication.shared.keyWindow         → UIApplication.safeKeyWindow
//    UIApplication.shared.windows           → UIApplication.safeWindows
//    UIApplication.shared.windows.first ... → UIApplication.safeKeyWindow
//

extension UIApplication {

    /// Safe replacement for `keyWindow with active state` (deprecated iOS 13)
    @objc static var safeActiveWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.windows
            .first(where: \.isKeyWindow)
    }
    
    /// Safe replacement for `keyWindow` (deprecated iOS 13)
    @objc static var safeKeyWindow: UIWindow? {
        if let safeActiveWindow = UIApplication.safeActiveWindow {
            return safeActiveWindow
        }
        
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first(where: \.isKeyWindow)
    }

    /// Safe replacement for `windows` (deprecated iOS 15)
    @objc static var safeWindows: [UIWindow] {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
    }
}

// MARK: - ═══════════════════════════════════════════════════════════════
// MARK:   7. UIApplicationDelegate Lifecycle (deprecated iOS 26.0)
// MARK: ═══════════════════════════════════════════════════════════════
//
//  HOW TO USE:
//    1. Make your AppDelegate inherit from SafeAppDelegate
//    2. Override the `handle*` methods instead of the old UIApplicationDelegate methods
//    3. SafeAppDelegate auto-routes: old delegate → handleX / scene delegate → handleX
//
//  BEFORE:
//    class AppDelegate: NSObject, UIApplicationDelegate {
//        func applicationDidBecomeActive(_ application: UIApplication) { ... }
//    }
//
//  AFTER:
//    class AppDelegate: SafeAppDelegate {
//        override func handleDidBecomeActive() { ... }
//    }
//

/// Base AppDelegate that bridges old UIApplicationDelegate → UISceneDelegate methods.
/// Subclass this and override `handle*` methods. Works on both iOS < 26 and iOS >= 26.
open class SafeAppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Override these in your subclass

    /// Called when app/scene becomes active
    open func handleDidBecomeActive() {}

    /// Called when app/scene will resign active
    open func handleWillResignActive() {}

    /// Called when app/scene enters background
    open func handleDidEnterBackground() {}

    /// Called when app/scene will enter foreground
    open func handleWillEnterForeground() {}

    /// Called when app/scene opens a URL. Return true if handled.
    open func handleOpenURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool { false }

    /// Called when continuing a user activity. Return true if handled.
    open func handleContinueUserActivity(_ userActivity: NSUserActivity) -> Bool { false }

    /// Called when continuing a user activity with restoration handler.
    /// Default forwards to handleContinueUserActivity(_:).
    open func handleContinueUserActivity(_ userActivity: NSUserActivity,
                                          restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        handleContinueUserActivity(userActivity)
    }

    /// Called when user activity is updated
    open func handleDidUpdateUserActivity(_ userActivity: NSUserActivity) {}

    /// Called when continuing user activity fails
    open func handleDidFailToContinueUserActivity(type: String, error: Error) {}

    /// Called when app will continue user activity
    open func handleWillContinueUserActivity(type: String) -> Bool { false }

    /// Called when performing shortcut action
    open func handlePerformAction(for shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(false)
    }

    // CloudKit share: uncomment if your project uses CloudKit
    // open func handleDidAcceptCloudKitShare(_ cloudKitShareMetadata: CKShareMetadata) {}

    /// Called when scene connects. Override to set up rootViewController.
    /// `window` is pre-created; set `window.rootViewController` and call `window.makeKeyAndVisible()`.
    open func handleSceneWillConnect(window: UIWindow, windowScene: UIWindowScene, scene: SafeSceneDelegate) {}
    
    open func handleSceneDidDisconnect(_ scene: UIScene) { }

    // MARK: - UIApplicationDelegate (deprecated iOS 26, auto-forwarded)

    public func applicationDidBecomeActive(_ application: UIApplication) {
        guard #unavailable(iOS 26.0) else { return }
        handleDidBecomeActive()
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        guard #unavailable(iOS 26.0) else { return }
        handleWillResignActive()
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        handleDidEnterBackground()
    }

    public func applicationWillEnterForeground(_ application: UIApplication) {
        guard #unavailable(iOS 26.0) else { return }
        handleWillEnterForeground()
    }

    public func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard #unavailable(iOS 26.0) else { return false }
        return handleOpenURL(url, options: options)
    }

    public func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard #unavailable(iOS 26.0) else { return false }
        return handleContinueUserActivity(userActivity, restorationHandler: restorationHandler)
    }

    public func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        guard #unavailable(iOS 26.0) else { return }
        handleDidUpdateUserActivity(userActivity)
    }

    public func application(_ application: UIApplication,
                     didFailToContinueUserActivityWithType userActivityType: String,
                     error: Error) {
        guard #unavailable(iOS 26.0) else { return }
        handleDidFailToContinueUserActivity(type: userActivityType, error: error)
    }

    public func application(_ application: UIApplication,
                     willContinueUserActivityWithType userActivityType: String) -> Bool {
        guard #unavailable(iOS 26.0) else { return false }
        return handleWillContinueUserActivity(type: userActivityType)
    }

    public func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        guard #unavailable(iOS 26.0) else { return completionHandler(false) }
        handlePerformAction(for: shortcutItem, completionHandler: completionHandler)
    }

    // MARK: - Scene Delegate Configuration

    /// On iOS 26+: returns SafeSceneDelegate to handle deprecated app delegate methods.
    /// On iOS < 26: returns default config from Info.plist so existing setup is preserved.
    public func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "DefaultConfiguration", sessionRole: connectingSceneSession.role)
        config.delegateClass = SafeSceneDelegate.self
        return config
    }
}

/// Scene delegate that forwards to SafeAppDelegate's handle* methods.
/// Automatically used when SafeAppDelegate is the app delegate.

final public class SceneConnectionOptions {
    var urlContexts: Set<UIOpenURLContext>?
    var userActivities: Set<NSUserActivity>?
    var notificationResponse: UNNotificationResponse?
    var shortcutItem: UIApplicationShortcutItem?
}

open class SafeSceneDelegate: UIResponder, UIWindowSceneDelegate {

    public var window: UIWindow?
    public let sceneLaunchOptions = SceneConnectionOptions()

    private var appDelegate: SafeAppDelegate? {
        UIApplication.shared.delegate as? SafeAppDelegate
    }

    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let win = UIWindow(windowScene: windowScene)
        self.window = win        
        appDelegate?.handleSceneWillConnect(window: win, windowScene: windowScene, scene: self)

        sceneLaunchOptions.urlContexts = connectionOptions.urlContexts
        sceneLaunchOptions.userActivities = connectionOptions.userActivities
        sceneLaunchOptions.shortcutItem = connectionOptions.shortcutItem
        sceneLaunchOptions.notificationResponse = connectionOptions.notificationResponse
    }

    public func sceneDidBecomeActive(_ scene: UIScene) {
        appDelegate?.handleDidBecomeActive()

        if let urlContexts = sceneLaunchOptions.urlContexts, !urlContexts.isEmpty {
            self.scene(scene, openURLContexts: urlContexts)
            sceneLaunchOptions.urlContexts = nil
        } else if let userActivity = sceneLaunchOptions.userActivities?.first {
            self.scene(scene, continue: userActivity)
            sceneLaunchOptions.userActivities = nil
        } else if let shortcutItem = sceneLaunchOptions.shortcutItem {
            if let scene = scene as? UIWindowScene {
                self.windowScene(scene , performActionFor: shortcutItem, completionHandler: { _ in })
            }
            sceneLaunchOptions.shortcutItem = nil
        } else if let notificationResponse = sceneLaunchOptions.notificationResponse {
            VNPInboxManager.shared().handle(notificationResponse)
            sceneLaunchOptions.notificationResponse = nil
        }
    }

    public func sceneWillResignActive(_ scene: UIScene) {
        appDelegate?.handleWillResignActive()
    }

    public func sceneDidEnterBackground(_ scene: UIScene) {
        appDelegate?.handleDidEnterBackground()
    }

    public func sceneWillEnterForeground(_ scene: UIScene) {
        appDelegate?.handleWillEnterForeground()
    }

    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            _ = appDelegate?.handleOpenURL(context.url, options: [:])
        }
    }

    public func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        _ = appDelegate?.handleContinueUserActivity(userActivity)
    }

    public func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        appDelegate?.handleDidUpdateUserActivity(userActivity)
    }

    public func scene(_ scene: UIScene, didFailToContinueUserActivityWithType userActivityType: String,
               error: Error) {
        appDelegate?.handleDidFailToContinueUserActivity(type: userActivityType, error: error)
    }

    public func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        _ = appDelegate?.handleWillContinueUserActivity(type: userActivityType)
    }

    public func windowScene(_ windowScene: UIWindowScene,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        appDelegate?.handlePerformAction(for: shortcutItem, completionHandler: completionHandler)
    }
    
    public func sceneDidDisconnect(_ scene: UIScene) {
        appDelegate?.handleSceneDidDisconnect(scene)
    }
}

// MARK: - ═══════════════════════════════════════════════════════════════
// MARK:   12. UIMenu.Identifier.newScene → newItem (deprecated iOS 26.0)
// MARK: ═══════════════════════════════════════════════════════════════
//
//  FIND & REPLACE:
//    UIMenu.Identifier.newScene → UIMenu.Identifier.safeNewScene
//    .newScene                  → .safeNewScene
//

extension UIMenu.Identifier {

    /// Safe replacement for `.newScene` → `.newItem` on iOS 26+
    static var safeNewScene: UIMenu.Identifier {
        if #available(iOS 26.0, *) {
            return .newItem
        }
        return .newScene
    }
}

// MARK: - ═══════════════════════════════════════════════════════════════
// MARK:   13. UINavigationItem.SearchBarPlacement.inline → .integrated
// MARK:       (deprecated iOS 26.0)
// MARK: ═══════════════════════════════════════════════════════════════
//
//  FIND & REPLACE:
//    .inline → .safeInline
//

@available(iOS 16.0, *)
extension UINavigationItem.SearchBarPlacement {

    /// Safe replacement for `.inline` → `.integrated` on iOS 26+
    static var safeInline: UINavigationItem.SearchBarPlacement {
        if #available(iOS 26.0, *) {
            return .integrated
        }
        return .inline
    }
}

import LocalAuthentication

// MARK: - ═══════════════════════════════════════════════════════════════
// MARK:   14. LAContext evaluatedPolicyDomainState (deprecated iOS 18.0)
// MARK: ═══════════════════════════════════════════════════════════════
//
//  FIND & REPLACE:
//  evaluatedPolicyDomainState → safeEvaluatedPolicyDomainState
//
extension LAContext {
    @objc var safeEvaluatedPolicyDomainState: Data? {
        if #available(iOS 18.0, *) {
            return domainState.biometry.stateHash
        }
        return self.evaluatedPolicyDomainState
    }
}
