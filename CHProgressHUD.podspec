
Pod::Spec.new do |s|

  s.name         = "CHProgressHUD"
  s.version      = "0.1.4"
  s.summary      = "A HUD UIView for ios "
  s.author       = { "chausson" => "232564026@qq.COM" }

  s.description  = "修复快速显示隐藏导致页面显示错误的bug "
  s.homepage     = "https://github.com/chausson/CHProgressHUD.git"

  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/chausson/CHProgressHUD.git", :tag => "0.1.4" }

  s.source_files  = "CHProgressHUD/*.{h,m}"
  # s.dependency "JSONKit", "~> 1.4"

end
