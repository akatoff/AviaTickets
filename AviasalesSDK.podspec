Pod::Spec.new do |s|

	s.name         = "AviasalesSDK"
	s.version      = "1.3.3-beta1"
	s.summary      = "Include avias tickets search and buy process in your apps."
	s.description  = <<-DESC
Aviasales SDK lets you create custom process of searching and buying tickets to flights.
                   DESC

	s.homepage     = "https://github.com/KosyanMedia/Aviasales-iOS-SDK"
	s.license      = { :type => "MIT", :file => "LICENSE" }
	s.author             = { "Aviasales iOS Team" => "support@aviasales.ru" }
	s.platform     = :ios, "7.0"
	s.source       = { :git => "https://github.com/KosyanMedia/Aviasales-iOS-SDK.git", :branch =>"1.3.3-beta1", :tag => "1.3.3-beta1" }
	s.public_header_files = "AviasalesLib/Headers/*.h"
	s.vendored_libraries = "AviasalesLib/libAviasales.a"

end
