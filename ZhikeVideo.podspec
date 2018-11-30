
Pod::Spec.new do |s|

  s.name         = "ZhikeVideo"
  s.version      = "1.0.2"
  s.summary      = "video for iOS develop"

  s.homepage     = "https://github.com/smartliuliu/ZhikeAVVideo"
  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author        = { "liu" => "1172436954@qq.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/smartliuliu/ZhikeAVVideo.git", :tag => s.version }
  s.source_files  = "ZhikeVideo/**/*.{h,m}",'Pods/**/*.{h,m}'
  s.resource_bundle = { 'ZhikeVideo' => ['ZhikeVideo/Resources/*.png'] }
  #s.exclude_files = "ZhikeVideo/Exclude"
  s.public_header_files = "ZhikeVideo/**/*.h"

  s.frameworks = 'UIKit', 'AVFoundation'
  s.dependency 'Masonry'
  s.dependency 'SDWebImage'
  s.requires_arc = true

end
