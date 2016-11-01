Pod::Spec.new do |s|
     
  s.name         = "CHProgressHUD"
  s.version      = "0.4"
  s.summary      = "A HUD UIView for ios "
  s.author       = { "chausson" => "232564026@qq.COM" }
  s.license      = "MIT"
  s.description  = "修复显示文字没有做非空判断处理，目前处理是没有传入文字不做任何事"
  s.homepage     = "https://github.com/chausson/CHProgressHUD.git"
    
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/chausson/CHProgressHUD.git", :tag => "0.3" }
    
  s.source_files  = "CHProgressHUD/*.{h,m}"
    
end
