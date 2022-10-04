source 'https://cdn.cocoapods.org'

platform :ios, '14.0'
install! 'cocoapods', :deterministic_uuids => false
use_frameworks!
inhibit_all_warnings!

workspace 'jsonPlaceholder.xcworkspace'

def commonPods
  pod 'Alamofire'
  pod 'RxCocoa'
  pod 'RxSwift'
  pod 'RxSwiftExt'
  pod 'FLEX'

  pod 'ReSwift'
  pod 'ReSwiftThunk'
  
  pod 'SwiftyBeaver'
  pod 'SwiftyJSON'
  pod 'Swinject'
end

abstract_target 'JSONPlaceholderProjects' do
  target 'jsonPlaceholder' do
    project 'jsonPlaceholder.xcodeproj'
    commonPods
  end

  target 'jsonPlaceholderTests' do
    commonPods
  end
end
