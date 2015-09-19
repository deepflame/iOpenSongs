source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.1'

link_with 'Release', 'Beta', 'Acceptance Tests'

# UI
pod 'FRLayeredNavigationController', :git => 'https://github.com/deepflame/FRLayeredNavigationController'
pod 'MBProgressHUD'
pod 'TDBadgedCell', :podspec => 'Other Sources/podspecs/TDBadgedCell.podspec'
pod 'SYPaginator'

# Core
pod 'MagicalRecord'
pod 'Dropbox-iOS-SDK'
pod 'FormatterKit/UnitOfInformationFormatter'
pod 'BlocksKit'
pod 'QuickDialog', git: 'https://github.com/escoz/QuickDialog.git'
pod 'RMStore'
pod 'RMStore/KeychainPersistence'
pod 'RMStore/TransactionReceiptVerificator'
#pod 'WebViewJavascriptBridge'

# User Services
pod 'iNotify'
pod 'Appirater'
pod 'uservoice-iphone-sdk'
pod 'GoogleAnalytics'

# Development
pod 'PonyDebugger'

# Testing
target 'Acceptance Tests', :exclusive => true do
  pod 'KIF', '~> 3.0.0'
end

