Pod::Spec.new do |spec|
  spec.name         = 'UIXCurrencyTextField'
  spec.version      = '1.0.0'
  spec.license      = 'MIT'
  spec.homepage	    = 'https://github.com/gumbright/UIXCurrencyTextField'
  spec.authors      =  {'Guy Umbright' => 'guy@umbrightconsulting.com'} 
  spec.source       =  {:git => 'https://github.com/gumbright/UIXCurrencyTextField.git'}
  spec.source_files =  'UIXCurrencyTextField/*.{h,m}'
  spec.requires_arc = true

  s.summary          = "An ATM like currency entry view"
  s.screenshots      = "www.umbrightconsulting.com/cocoapods/uixcurrencytextfield/screenshot1.png"

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'

  s.source_files = 'Classes'

  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'

end