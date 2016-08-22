Pod::Spec.new do |s|
     
  s.name         = "CHProgressHUD"
  s.version      = "0.3"
  s.summary      = "A HUD UIView for ios "
  s.author       = { "chausson" => "232564026@qq.COM" }
  s.license      = "MIT"
  s.description  = "文字显示高度自适应，增加Custom自定义View"
  s.homepage     = "https://github.com/chausson/CHProgressHUD.git"
    
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/chausson/CHProgressHUD.git", :tag => "0.3" }
    
  s.source_files  = "CHProgressHUD/*.{h,m}"
    
end
