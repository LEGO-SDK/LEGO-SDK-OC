Pod::Spec.new do |s|
  s.name         = "LEGO-SDK"
  s.version      = "0.4.3"
  s.summary      = "LEGO-SDK is bridge via WebView and Native."
  s.description  = <<-DESC
                      LEGO-SDK is bridge via WebView and Native.
                      SDK Provides lots of APIs.
                   DESC
  s.homepage     = "http://code.yy.com/LEGO-SDK/LEGO-SDK-OC"
  s.license      = "Apache License, Version 2.0"
  s.author             = { "PonyCui" => "cuis@vip.qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "http://code.yy.com/ued/LEGO-SDK-OC.git", :tag => s.version }
  s.requires_arc = true
  s.subspec 'Core' do |core|
    core.source_files = 'SDK/Core/*.{h,m}', 'SDK/WebView/UIWebView/*.{h,m}', 'SDK/WebView/WKWebView/*.{h,m}'
    core.framework = 'JavaScriptCore'
    core.weak_framework = 'WebKit'
  end
  s.subspec 'AutoInject' do |auto|
    auto.source_files = 'SDK/WebView/AutoInject/*.{h,m}'
    auto.dependency 'LEGO-SDK/Core'
    auto.framework = 'JavaScriptCore'
    auto.weak_framework = 'WebKit'
  end
  s.subspec 'API' do |api|
    api.dependency 'LEGO-SDK/Core'
    api.subspec 'Native' do |native|
      native.subspec 'Call' do |m|
        m.source_files = 'SDK/Modules/Native/Call/*.{h,m}'
      end
      native.subspec 'Check' do |m|
        m.source_files = 'SDK/Modules/Native/Check/*.{h,m}'
      end
      native.subspec 'DataModel' do |m|
        m.source_files = 'SDK/Modules/Native/DataModel/*.{h,m}'
      end
      native.subspec 'Device' do |m|
        m.source_files = 'SDK/Modules/Native/Device/*.{h,m}'
      end
      native.subspec 'FileManager' do |m|
        m.source_files = 'SDK/Modules/Native/FileManager/*.{h,m}'
      end
      native.subspec 'HTTPRequest' do |m|
        m.source_files = 'SDK/Modules/Native/HTTPRequest/*.{h,m}'
      end
      native.subspec 'Notification' do |m|
        m.source_files = 'SDK/Modules/Native/Notification/*.{h,m}'
      end
      native.subspec 'OpenURL' do |m|
        m.source_files = 'SDK/Modules/Native/OpenURL/*.{h,m}'
      end
      native.subspec 'Pasteboard' do |m|
        m.source_files = 'SDK/Modules/Native/Pasteboard/*.{h,m}'
      end
      native.subspec 'UserDefaults' do |m|
        m.source_files = 'SDK/Modules/Native/UserDefaults/*.{h,m}'
      end
    end
    api.subspec 'UI' do |ui|
      ui.subspec 'ActionSheet' do |m|
        m.source_files = 'SDK/Modules/UI/ActionSheet/*.{h,m}'
      end
      ui.subspec 'AlertView' do |m|
        m.source_files = 'SDK/Modules/UI/AlertView/*.{h,m}'
      end
      ui.subspec 'ImagePreviewer' do |m|
        m.source_files = 'SDK/Modules/UI/ImagePreviewer/*.{h,m}'
      end
      ui.subspec 'ModalController' do |m|
        m.source_files = 'SDK/Modules/UI/ModalController/*.{h,m}'
        m.dependency 'LEGO-SDK/API/UI/ViewController'
      end
      ui.subspec 'NavigationController' do |m|
        m.source_files = 'SDK/Modules/UI/NavigationController/*.{h,m}'
        m.dependency 'LEGO-SDK/API/UI/ViewController'
      end
      ui.subspec 'NavigationItem' do |m|
        m.source_files = 'SDK/Modules/UI/NavigationItem/*.{h,m}'
      end
      ui.subspec 'PageState' do |m|
        m.source_files = 'SDK/Modules/UI/PageState/*.{h,m}'
        m.dependency 'LEGO-SDK/API/UI/ViewController'
      end
      ui.subspec 'Picker' do |m|
        m.source_files = 'SDK/Modules/UI/Picker/*.{h,m}'
      end
      ui.subspec 'ProgressView' do |m|
        m.source_files = 'SDK/Modules/UI/ProgressView/*.{h,m}'
      end
      ui.subspec 'Refresh' do |m|
        m.source_files = 'SDK/Modules/UI/Refresh/*.{h,m}'
      end
      ui.subspec 'Toast' do |m|
        m.source_files = 'SDK/Modules/UI/Toast/*.{h,m}'
      end
      ui.subspec 'ViewController' do |m|
        m.source_files = 'SDK/Modules/UI/ViewController/*.{h,m}', 'SDK/Modules/UI/Page/*.{h,m}'
      end
    end
    api.subspec 'WebView' do |webview|
      webview.subspec 'Pack' do |m|
        m.source_files = 'SDK/Modules/WebView/Pack/*.{h,m}'
        m.dependency 'SSZipArchive'
      end
    end
  end
end
