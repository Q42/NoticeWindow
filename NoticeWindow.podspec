Pod::Spec.new do |s|
  s.name             = "NoticeWindow"
  s.version          = "0.9.2"
  s.summary          = "Present your custom notices in the application window."

  s.description      = <<-DESC
  Present your custom notices in the application window so the notice isn't lost after leaving the screen.
                       DESC

  s.homepage         = "https://github.com/Q42/NoticeWindow"
  s.license          = 'MIT'
  s.author           = { "Tim van Steenis" => "tims@q42.nl" }
  s.source           = { :git => "https://github.com/Q42/NoticeWindow.git", :tag => s.version }

  s.platform      = :ios, '12.0'
  s.swift_version = '5.1'

  s.source_files = 'Pod/Classes/*'
  s.resource_bundles = {
    'NoticeWindow' => ['Pod/Resources/*.xib', 'Pod/Assets/*.png']
  }
end

