#
# Be sure to run `pod lib lint TYSMBaseKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TYSMBaseKit'
  s.version          = '0.1.0'
  s.summary          = 'TYSMBaseKit '
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  1. 引入基础组件库，UI、系统工具、日志系统、路由
  2. 详情看 TYSMBaseKit.h
  3. 兼容 osx （少部分）
  DESC
  
  s.homepage         = 'https://github.com/cookies-J/TYSMBaseKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cooljele@gmail.com' => 'cookiesfunny@qq.com' }
  s.source           = { :git => 'https://github.com/cookies-J/TYSMBaseKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.14'
  
  # TYSMGBDeviceInfo 源码分了 iOS、macos ，这里需要按平台处理
  # 参考 https://github.com/lmirosevic/GBDeviceInfo/blob/master/GBDeviceInfo.podspec
  s.subspec 'TYSMGBDeviceInfo' do |deviceInfo|
    deviceInfo.ios.source_files          =
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/*_iOS.{h,m}',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/*_Common.{h,m}',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/TYSMDeviceInfo.h',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/TYSMDeviceInfoInterface.h',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/TYSMDeviceInfo_Subclass.h'
    
    deviceInfo.ios.public_header_files   =
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/*_iOS.h',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/*_Common.h',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/TYSMDeviceInfo.h',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/TYSMDeviceInfoInterface.h',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/TYSMDeviceInfo_Subclass.h'
    
    deviceInfo.osx.source_files          =
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/*_OSX.{h,m}',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/*_Common.{h,m}',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/TYSMDeviceInfo.h',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/TYSMDeviceInfoInterface.h',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/TYSMDeviceInfo_Subclass.h'
    
    deviceInfo.osx.public_header_files   =
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/*_OSX.h',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/*_Common.h',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/TYSMDeviceInfo.h',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/TYSMDeviceInfoInterface.h',
    'TYSMBaseKit/Classes/Multi Platform/TYSMGBDeviceInfo/TYSMDeviceInfo_Subclass.h'
    
    deviceInfo.osx.frameworks            = 'Cocoa', 'CoreServices', 'Foundation'
    deviceInfo.ios.frameworks            = 'Foundation'
  end
  
  # 所有未分类的包在这里
  s.subspec 'src' do | src |
    src.osx.source_files =
    'TYSMBaseKit/Classes/src/TYSMLog/*',
#    'TYSMBaseKit/Classes/src/TYSMBackgroundTask/*',
    'TYSMBaseKit/Classes/src/TYSMDeviceInfo'
    
    src.ios.source_files = 'TYSMBaseKit/Classes/src/**/*'
    src.ios.frameworks = 'UIKit','Foundation'
    src.osx.frameworks            = 'Cocoa', 'CoreServices', 'Foundation'
    src.ios.dependency "XXNibBridge"
  end
  
  s.subspec 'DB' do |sna|
#    sna.requires_arc = false
    sna.dependency "WCDB"
    sna.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/WCDB"}
  end
  
  # 路由组件
  s.subspec 'TYSMCTMediator' do | m |
    m.source_files = 'TYSMBaseKit/Classes/TYSM_CTMediator/*'
  end
  
  s.source_files = 'TYSMBaseKit/Classes/*'
  
  s.resource_bundles = {
    'TYSMBaseKit' => ['TYSMBaseKit/Assets/*']
  }
  
#  # 处理Xcode 12 M1 芯片编译错误
  s.pod_target_xcconfig       = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' ,"ONLY_ACTIVE_ARCH" => 'YES' }
  s.user_target_xcconfig      = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' ,"ONLY_ACTIVE_ARCH" => 'YES'}
  
  s.public_header_files = 'TYSMBaseKit/Classes/TYSMBaseKit.h'
#  s.dependency "CTMediator"
  
end
