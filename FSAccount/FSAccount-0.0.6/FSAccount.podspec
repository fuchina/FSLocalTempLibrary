Pod::Spec.new do |s|
  s.name = "FSAccount"
  s.version = "0.0.6"
  s.summary = "FSAccount is a tool for show logs when app run"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"fudon"=>"1245102331@qq.com"}
  s.homepage = "https://github.com/fuchina/FSAccount"
  s.description = "This is a very small software library, offering a few methods to help with programming."
  s.frameworks = ["UIKit", "AVFoundation", "CoreGraphics", "Security", "SystemConfiguration"]
  s.libraries = ["c++", "sqlite3", "z"]
  s.source = { :path => '.' }

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   = 'ios/FSAccount.framework'
end
