//
//  UserInformationiCloudViewModel.swift
//  ThingLog
//
//  Created by hyunsu on 2021/10/31.
//
import Foundation

/// `KeyValueStorage`를 이용하여 유저정보를 가져오고 업데이트하는 ViewModel
final class UserInformationiCloudViewModel: UserInformationViewModelable {
    func fetchUserInformation(completion: @escaping (UserInformationable?) -> Void) {
        if NSUbiquitousKeyValueStore.default.string(forKey: KeyStoreName.userAliasName.name) == nil {
            completion(nil)
            return
        }
        let userName: String = NSUbiquitousKeyValueStore.default.string(forKey: KeyStoreName.userAliasName.name) ?? ""
        let userOneLine: String = NSUbiquitousKeyValueStore.default.string(forKey: KeyStoreName.userOneLineIntroduction.name) ?? ""
        let darkMode: Bool = NSUbiquitousKeyValueStore.default.bool(forKey: KeyStoreName.isAutomatedDarkMode.name)
        
        let userInformation: UserInformation = UserInformation(userAliasName: userName,
                                                               userOneLineIntroduction: userOneLine,
                                                               isAumatedDarkMode: darkMode)
        completion(userInformation)
    }
    
    func updateUserInformation(_ user: UserInformationable) {
        
        NSUbiquitousKeyValueStore.default.set(user.userAliasName,
                                              forKey: KeyStoreName.userAliasName.name)
        NSUbiquitousKeyValueStore.default.set(user.userOneLineIntroduction,
                                              forKey: KeyStoreName.userOneLineIntroduction.name)
        NSUbiquitousKeyValueStore.default.set(user.isAumatedDarkMode,
                                              forKey: KeyStoreName.isAutomatedDarkMode.name)
        NSUbiquitousKeyValueStore.default.synchronize()
        // TODO: - ⚠️ name 이름 변경 예정 - Notification extension하여
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userInformation"), object: nil)
    }
    
    func resetUserInformation() {
        NSUbiquitousKeyValueStore.default.removeObject(forKey: KeyStoreName.userAliasName.name)
        NSUbiquitousKeyValueStore.default.removeObject(forKey: KeyStoreName.userOneLineIntroduction.name)
        NSUbiquitousKeyValueStore.default.removeObject(forKey: KeyStoreName.isAutomatedDarkMode.name)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func subscribeUserInformationChange(completion: @escaping (UserInformationable?) -> Void) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "userInformation"), object: nil, queue: .main) { [weak self] _ in
            self?.fetchUserInformation(completion: { userInformation in
                completion(userInformation)
            })
        }
    }
}