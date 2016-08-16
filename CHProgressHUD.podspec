Pod::Spec.new do |s|
     
  s.name         = "CHProgressHUD"
  s.version      = "0.2"
  s.summary      = "A HUD UIView for ios "
  s.author       = { "chausson" => "232564026@qq.COM" }
  s.license      = "MIT"
  s.description  = "增加自定义view和自定义view旋转的模式 "
  s.homepage     = "https://github.com/chausson/CHProgressHUD.git"
    
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/chausson/CHProgressHUD.git", :tag => "0.2" }
    
  s.source_files  = "CHProgressHUD/*.{h,m}"
    
end
