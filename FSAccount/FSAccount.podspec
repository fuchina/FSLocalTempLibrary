Pod::Spec.new do |s|
  s.name             = 'FSAccount'
  s.version          = '0.0.8'
  s.summary          = 'FSAccount is a tool for show logs when app run'
  s.description      = <<-DESC
		This is a very small software library, offering a few methods to help with programming.
    DESC

  s.homepage         = 'https://github.com/fuchina/FSAccount'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fudon' => '1245102331@qq.com' }
  
  s.source           = { :git => 'https://github.com/fuchina/FSLocalTempLibrary.git', :tag => s.version.to_s}

  #s.public_header_files = 'FSAccount/Classes/*.h','FSAccount/Classes/imports/*.h'
  
  s.ios.deployment_target = '8.0'
  s.source_files = 'FSAccount/Classes/*.{h,m}','FSAccount/Classes/imports/*.{h,m}'
  s.frameworks =  'UIKit','AVFoundation', 'CoreGraphics', 'Security', 'SystemConfiguration'
  s.libraries = 'c++', 'sqlite3', 'z'
  
  s.dependency   'FSToast'
  s.dependency   'FSUIKit'  
  s.dependency   'FSTuple'  
  s.dependency   'FSDBMaster'  
  s.dependency   'FSShare'
  s.dependency   'FSViewToImage'
  s.dependency   'YYKit','1.0.9'

end
