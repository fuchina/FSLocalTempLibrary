Pod::Spec.new do |s|
  s.name             = 'FSAccount'
  s.version          = '0.0.2'
  s.summary          = 'FSAccount is a tool for show logs when app run'
  s.description      = <<-DESC
		This is a very small software library, offering a few methods to help with programming.
    DESC

  s.homepage         = 'https://github.com/fuchina/FSAccount'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fudon' => '1245102331@qq.com' }
  
  s.source           = { :file => "/Users/fudonfuchina/Documents/Simple_components/FSAccount"}

  s.ios.deployment_target = '8.0'
  s.source_files = 'FSAccount/Classes/*','FSAccount/Classes/imports/*'
  s.frameworks = 'UIKit'
  
  s.dependency   'FSUIKit'
  s.dependency   'FSToast'
  s.dependency   'FSKit'  
  s.dependency   'FSUIKit'  
  s.dependency   'FSTuple'  
  s.dependency   'FSTrack'  
  s.dependency   'FSDBMaster'  
  s.dependency   'MJRefresh','3.1.15.7' 
  s.dependency   'FSShare'
  s.dependency   'FSViewToImage'
  s.dependency   'YYKit','1.0.9'

end
