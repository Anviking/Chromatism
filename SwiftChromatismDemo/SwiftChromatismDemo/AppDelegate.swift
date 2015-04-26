//
//  AppDelegate.swift
//  SwiftChromatismDemo
//
//  Created by Johannes Lund on 2014-06-15.
//  Copyright (c) 2014 anviking. All rights reserved.
//

import UIKit
import Chromatism

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        // Override point for customization after application launch.
        
        // Load demo text
        let url = NSBundle.mainBundle().URLForResource("swift", withExtension: "txt");
        let string = NSString(contentsOfURL: url!, encoding: NSUTF8StringEncoding, error: nil) as! String
        
        let viewController = JLTextViewController(text: string, language: .Swift, theme: .Dusk)
        
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Resign", style: .Plain, target: viewController.textView, action:"resignFirstResponder")
        
        let navigationController = UINavigationController(rootViewController: viewController)
        viewController.title = "Chromatism";
        
        self.window!.rootViewController = navigationController
        self.window!.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}