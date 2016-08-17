Pod::Spec.new do |s|

  s.name         = "LEGO-SDK"
  s.version      = "0.3.0"
  s.summary      = "LEGO-SDK is bridge via WebView and Native."
  s.description  = <<-DESC
                      LEGO-SDK is bridge via WebView and Native.
                      SDK Provides lots of APIs.
                   DESC
  s.homepage     = "http://code.yy.com/LEGO-SDK/LEGO-SDK-OC"
  s.license      = "Apache License, Version 2.0"
  s.author             = { "PonyCui" => "cuis@vip.qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "http://code.yy.com/LEGO-SDK/LEGO-SDK-OC.git" }
  s.requires_arc = true

  s.subspec 'Core' do |core|
    core.source_files = 'SDK/Core/*.{h,m}', 'SDK/WebView/UIWebView/*.{h,m}', 'SDK/WebView/WKWebView/*.{h,m}'
    core.weak_framework = 'WebKit'
  end

  s.subspec 'AutoInject' do |auto|
    auto.source_files = 'SDK/WebView/AutoInject/*.{h,m}'
  end

end
