# Contributors outside of DragonRuby who also hold Copyright: Michał Dudziński
# Copyright 2019 DragonRuby LLC
# MIT License
# ios_wizard.rb has been released under MIT (*only this file*).

class WizardException < Exception
  attr_accessor :console_primitives

  def initialize *console_primitives
    @console_primitives = console_primitives
  end
end

class IOSWizard
  include Metadata

  def initialize
    @doctor_executed_at = 0
  end

  def relative_path
    (File.dirname $gtk.binary_path)
  end

  def steps
    @steps ||= []
  end

  def steps_development_build
    [
      :check_for_xcode,
      :check_for_brew,
      :check_for_certs,
      :check_for_device,
      :check_for_dev_profile,
      :determine_team_identifier,
      :determine_app_name,
      :determine_app_id,
      :blow_away_temp,
      :stage_app,
      :development_write_info_plist,
      :write_entitlements_plist,
      :compile_icons,
      :create_payload_directory,
      :code_sign_payload,
      :create_ipa,
      :deploy
    ]
  end

  def steps_production_build
    [
      :check_for_xcode,
      :check_for_brew,
      :check_for_certs,
      :check_for_distribution_profile,
      :determine_team_identifier,
      :determine_app_name,
      :determine_app_id,
      :blow_away_temp,
      :stage_app,
      :production_write_info_plist,
      :write_entitlements_plist,
      :compile_icons,
      :create_payload_directory,
      :code_sign_payload,
      :create_ipa,
      :print_publish_help
    ]
  end

  def get_reserved_sprite png
    sprite_path = ".dragonruby/sprites/wizards/ios/#{png}"

    if !$gtk.ivar :rcb_release_mode
      sprite_path = "deploy_template/#{sprite_path}"
      $gtk.reset_sprite sprite_path
    end

    if !$gtk.read_file sprite_path
      log_error "png #{png} not found."
    end

    sprite_path
  end

  def start opts = {}
    @opts = opts

    unless $gtk.args.fn.eq_any? @opts[:env], :dev, :prod
      raise WizardException.new(
        "* $wizards.ios.start needs to be provided an environment option.",
        "** For development builds type: $wizards.ios.start env: :dev",
        "** For production builds type: $wizards.ios.start env: :prod"
      )
    end

    @production_build = (@opts[:env] == :prod)

    @version = determine_app_version @opts
    log_info "I will be using version: '#{@version}'" if @production_build

    @steps = steps_development_build
    @steps = steps_production_build if @production_build
    @certificate_name = nil
    init_wizard_status
    if @production_build
      log_info "Starting iOS Wizard so we can create a production build."
    else
      log_info "Starting iOS Wizard so we can deploy to your device."
    end
    @start_at = Kernel.global_tick_count
    steps.each do |m|
      log_info "Running step ~:#{m}~."
      result = (send m) || :success if @wizard_status[m][:result] != :success
      @wizard_status[m][:result] = result
      log_info "Running step ~:#{m}~ complete."
    end
    nil
  rescue Exception => e
    if e.is_a? WizardException
      $console.log.clear
      $console.archived_log.clear
      log "=" * $console.console_text_width
      e.console_primitives.each do |p|
        $console.add_primitive p
      end
      log "=" * $console.console_text_width
    else
      log_error e.to_s
    end

    $console.set_command "$wizards.ios.start env: :#{@opts[:env]}"
  end

  def always_fail
    return false if $gtk.ivar :rcb_release_mode
    return true
  end

  def check_for_xcode
    if !cli_app_exist?(xcodebuild_cli_app)
      raise WizardException.new(
        "* You need Xcode to use $wizards.ios.start.",
        { w: 75, h: 75, path: get_reserved_sprite("xcode.png") },
        "** 1. Go to http://developer.apple.com and register.",
        "** 2. Download Xcode 11.3+ from http://developer.apple.com/downloads.",
        "   NOTE: DO NOT install Xcode from the App Store. Use the link above.",
        { w: 700, h: 359, path: get_reserved_sprite("xcode-downloads.png") },
        "** 3. After installing. Open up Xcode to accept the EULA."
      )
    end
  end

  def check_for_brew
    if !cli_app_exist?('brew')
      raise WizardException.new(
        "* You need to install Brew.",
        { w: 700, h: 388, path: get_reserved_sprite("brew.png") },
        "** 1. Go to http://brew.sh.",
        "** 2. Copy the command that starts with `/bin/bash -c` on the site.",
        "** 3. Open Terminal and run the command you copied from the website.",
        { w: 700, h: 99, path: get_reserved_sprite("terminal.png") },
      )
    end
  end

  def init_wizard_status
    @wizard_status = {}
    steps.each do |m|
      @wizard_status[m] = { result: :not_started }
    end

    previous_step = nil
    next_step = nil
    steps.each_cons(2) do |current_step, next_step|
      @wizard_status[current_step][:next_step] = next_step
    end

    steps.reverse.each_cons(2) do |current_step, previous_step|
      @wizard_status[current_step][:previous_step] = previous_step
    end
  end

  def restart
    init_wizard_status
    start
  end

  def check_for_distribution_profile
    @provisioning_profile_path = "profiles/distribution.mobileprovision"
    if !($gtk.read_file @provisioning_profile_path)
      $gtk.system "mkdir -p #{relative_path}/profiles"
      $gtk.system "open #{relative_path}/profiles"
      $gtk.system "echo Download the mobile provisioning profile and place it here with the name distribution.mobileprovision > #{relative_path}/profiles/README.txt"
      raise WizardException.new(
        "* I didn't find a mobile provision.",
        "** 1. Go to http://developer.apple.com and click \"Certificates, IDs & Profiles\".",
        "** 2. Add an App Identifier.",
        "** 3. Select the App IDs option from the list.",
        { w: 700, h: 75, path: get_reserved_sprite("identifiers.png") },
        "** 4. Add your Device next. You can use idevice_id -l to get the UUID of your device.",
        { w: 365, h: 69, path: get_reserved_sprite("device-link.png") },
        "** 5. Create a Profile. Associate your certs, id, and device.",
        { w: 300, h: 122, path: get_reserved_sprite("profiles.png") },
        "** 6. Download the mobile provision and save it to 'profiles/development.mobileprovision'.",
        { w: 200, h: 124, path: get_reserved_sprite("profiles-folder.png") },
      )
    end
  end

  def check_for_dev_profile
    @provisioning_profile_path = "profiles/development.mobileprovision"
    if !($gtk.read_file @provisioning_profile_path)
      $gtk.system "mkdir -p #{relative_path}/profiles"
      $gtk.system "open #{relative_path}/profiles"
      $gtk.system "echo Download the mobile provisioning profile and place it here with the name development.mobileprovision > #{relative_path}/profiles/README.txt"
      raise WizardException.new(
        "* I didn't find a mobile provision.",
        "** 1. Go to http://developer.apple.com and click \"Certificates, IDs & Profiles\".",
        "** 2. Add an App Identifier.",
        "** 3. Select the App IDs option from the list.",
        { w: 700, h: 75, path: get_reserved_sprite("identifiers.png") },
        "** 4. Add your Device next. You can use idevice_id -l to get the UUID of your device.",
        { w: 365, h: 69, path: get_reserved_sprite("device-link.png") },
        "** 5. Create a Profile. Associate your certs, id, and device.",
        { w: 300, h: 122, path: get_reserved_sprite("profiles.png") },
        "** 6. Download the mobile provision and save it to 'profiles/development.mobileprovision'.",
        { w: 200, h: 124, path: get_reserved_sprite("profiles-folder.png") },
      )
    end
  end

  def provisioning_profile_path environment
    return "profiles/distribution.mobileprovision" if environment == :prod
    return "profiles/development.mobileprovision"
  end

  def determine_team_identifier
    @team_name = (team_identifier_from_provisioning_profile @opts[:env])
    log_info "Team Identifier is: #{@team_name}"
  end

  def determine_app_name
    @app_name = (provisioning_profile_xml @opts[:env])[:children].first[:children].first[:children][1][:children].first[:data]
    log_info "App name is: #{@app_name}."
  end

  def determine_app_version opts
    version = @opts[:version]
    unless version
      version = get_metadata[:version]
      version = version.start_with?('#') ? '1.0' : version.split('=').last
    end
    version.to_s
  end

  def provisioning_profile_xml environment
    xml = $gtk.read_file (provisioning_profile_path environment)
    scrubbed = xml.each_line.map do |l|
      if l.strip.start_with? "<"
        if l.start_with? '</plist>'
          '</plist>'
        elsif l.include? "Apple Inc."
          nil
        elsif l.include? '<data>'
          nil
        else
          l
        end
      else
        nil
      end
    end.reject { |l| !l }.join
    $gtk.parse_xml scrubbed
  end

  def app_id_from_provisioning_profile environment
    application_identifier_index = (provisioning_profile_xml environment)[:children][0][:children][0][:children][13][:children][0][:children][0][:data]
    (provisioning_profile_xml environment)[:children][0][:children][0][:children][13][:children].each.with_index do |node, i|
      if node[:children] && node[:children][0] && node[:children][0][:data] == "application-identifier"
        application_identifier_index = i
        break
      end
    end

    app_id_with_team_identifier = (provisioning_profile_xml environment)[:children].first[:children].first[:children][13][:children][application_identifier_index + 1][:children].first[:data]
    team_identifier = team_identifier_from_provisioning_profile environment
    app_id_with_team_identifier.gsub "#{team_identifier}.", ""
  end

  def team_identifier_from_provisioning_profile environment
    team_identifier_index = (provisioning_profile_xml environment)[:children][0][:children][0][:children][13][:children][0][:children][0][:data]

    (provisioning_profile_xml environment)[:children][0][:children][0][:children][13][:children].each.with_index do |node, i|
      if node[:children] && node[:children][0] && node[:children][0][:data] == "com.apple.developer.team-identifier"
        team_identifier_index = i
        break
      end
    end

    (provisioning_profile_xml environment)[:children].first[:children].first[:children][13][:children][team_identifier_index + 1][:children].first[:data]
  end

  def determine_app_id
    @app_id = app_id_from_provisioning_profile @opts[:env]

    log_info "App Identifier is set to : #{@app_id}"
  end

  def set_app_name name
    @app_name = name
    start
  end

  def set_dev_profile path
    if !$gtk.read_file path
      log_error "I couldn't find a development profile at #{path}."
      ask_for_dev_profile
    else
      @provisioning_profile_path = path
      start
    end
  end

  def blow_away_temp
    sh "rm -rf #{tmp_directory}"
  end

  def stage_app
    log_info "Staging."
    sh "mkdir -p #{tmp_directory}"
    sh "cp -R #{relative_path}/dragonruby-ios.app \"#{tmp_directory}/#{@app_name}.app\""
  end

  def set_app_id id
    log_info = "App Id set to: #{id}"
    @app_id = id
    start
  end

  def check_for_device
    log_info "Looking for device."

    if !cli_app_exist?(idevice_id_cli_app)
      raise WizardException.new(
         "* It doesn't look like you have the libimobiledevice iOS protocol library installed.",
         "** 1. Open Terminal.",
         { w: 700, h: 99, path: get_reserved_sprite("terminal.png") },
         "** 2. Run: `brew install libimobiledevice`.",
         { w: 500, h: 93, path: get_reserved_sprite("brew-install-libimobiledevice.png") },
      )
    end

    if connected_devices.length == 0
      raise WizardException.new("* I couldn't find any connected devices. Connect your iOS device to your Mac and try again.")
    end

    @device_id = connected_devices.first
    log_info "I will be using device with UUID #{@device_id}"
  end

  def check_for_certs
    log_info "Attempting to find certificates on your computer."

    if !cli_app_exist?(security_cli_app)
      raise WizardException.new(
              "* It doesn't look like you have #{security_cli_app}.",
              "** 1. Open Disk Utility and run First Aid.",
              { w: 700, h: 148, path: get_reserved_sprite("disk-utility.png") },
            )
    end

    if valid_certs.length == 0
      raise WizardException.new(
              "* It doesn't look like you have any valid certs installed.",
              "** 1. Open Xcode.",
              "** 2. Log into your developer account. Xcode -> Preferences -> Accounts.",
              { w: 700, h: 98, path: get_reserved_sprite("login-xcode.png") },
              "** 3. After logging in, select Manage Certificates...",
              { w: 700, h: 115, path: get_reserved_sprite("manage-certificates.png") },
              "** 4. Add a certificate for Apple Development.",
              { w: 700, h: 217, path: get_reserved_sprite("add-cert.png") },
      )
      raise "You do not have any Apple development certs on this computer."
    end

    if @production_build
      @certificate_name = valid_certs.find_all { |f| f[:name].include? "Distribution" }.first[:name]
    else
      @certificate_name = valid_certs.find_all { |f| f[:name].include? "Development" }.first[:name]
    end
    log_info "I will be using Certificate: '#{@certificate_name}'."
  end

  def idevice_id_cli_app
    "idevice_id"
  end

  def security_cli_app
    "/usr/bin/security"
  end

  def xcodebuild_cli_app
    "xcodebuild"
  end

  def valid_certs
    certs = sh("#{security_cli_app} -q find-identity -p codesigning -v").each_line.map do |l|
      if l.include?(")") && !l.include?("Developer ID") && (l.include?("Development") || l.include?("Distribution"))
        l.strip
      else
        nil
      end
    end.reject_nil.map do |l|
      number, id, name = l.split(' ', 3)
      name = name.gsub("\"", "") if name
      {
        number: 1,
        id: id,
        name: name
      }
    end
  end

  def connected_devices
    sh("idevice_id -l").strip.each_line.map do |l|
      l.strip
    end.reject { |l| l.length == 0 }
  end

  def cli_app_exist? app
    `which #{app}`.strip.length != 0
  end

  def write_entitlements_plist
    if @production_build
      entitlement_plist_string = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
        <dict>
                <key>application-identifier</key>
                <string>:app_id</string>
                <key>beta-reports-active</key>
                <true/>
        </dict>
</plist>
XML
    else
      entitlement_plist_string = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
        <dict>
                <key>application-identifier</key>
                <string>:app_id</string>
                <key>get-task-allow</key>
                <true/>
        </dict>
</plist>
XML
    end

    log_info "Creating Entitlements.plist"

    $gtk.write_file_root "tmp/ios/Entitlements.plist", entitlement_plist_string.gsub(":app_id", "#{@team_name}.#{@app_id}").strip

    sh "/usr/bin/plutil -convert binary1 \"#{tmp_directory}/Entitlements.plist\""
    sh "/usr/bin/plutil -convert xml1 \"#{tmp_directory}/Entitlements.plist\""

    @entitlement_plist_written = true
  end

  def code_sign_payload
    log_info "Signing app with #{@certificate_name}."

    sh "CODESIGN_ALLOCATE=\"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate\" /usr/bin/codesign -f -s \"#{@certificate_name}\" --entitlements #{tmp_directory}/Entitlements.plist \"#{tmp_directory}/ipa_root/Payload/#{@app_name}.app\""
    sh "CODESIGN_ALLOCATE=\"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate\" /usr/bin/codesign -f -s \"#{@certificate_name}\" --entitlements #{tmp_directory}/Entitlements.plist \"#{tmp_directory}/ipa_root/Payload/#{@app_name}.app/Runtime\""

    @code_sign_completed = true
  end

  def write_info_plist_distribution
    log_info "Adding Info.plist."

    <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>BuildMachineOSBuild</key>
        <string>20D91</string>
        <key>CFBundleDevelopmentRegion</key>
        <string>en</string>
        <key>CFBundleName</key>
        <string>:app_name</string>
        <key>CFBundleDisplayName</key>
        <string>A Dark Room</string>
        <key>CFBundleIdentifier</key>
        <string>:app_id</string>
        <key>CFBundleExecutable</key>
        <string>:app_name</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>5.6</string>
        <key>CFBundleSignature</key>
        <string>????</string>
        <key>CFBundleVersion</key>
        <string>5.6</string>
        <key>CFBundleIcons</key>
        <dict>
            <key>CFBundlePrimaryIcon</key>
            <dict>
                <key>CFBundleIconName</key>
                <string>AppIcon</string>
                <key>CFBundleIconFiles</key>
                <array>
                    <string>AppIcon60x60</string>
                </array>
            </dict>
        </dict>
        <key>CFBundleIcons~ipad</key>
        <dict>
            <key>CFBundlePrimaryIcon</key>
            <dict>
                <key>CFBundleIconName</key>
                <string>AppIcon</string>
                <key>CFBundleIconFiles</key>
                <array>
                    <string>AppIcon60x60</string>
                    <string>AppIcon76x76</string>
                    <string>AppIcon83.5x83.5</string>
                </array>
            </dict>
        </dict>
        <key>UILaunchStoryboardName</key>
        <string>SimpleSplash</string>
        <key>UIRequiresFullScreen</key>
        <true/>
        <key>ITSAppUsesNonExemptEncryption</key>
        <false/>
        <key>UIRequiredDeviceCapabilities</key>
        <array>
            <string>arm64</string>
        </array>
        <key>MinimumOSVersion</key>
        <string>10.3</string>
        <key>CFBundleSupportedPlatforms</key>
        <array>
            <string>iPhoneOS</string>
        </array>
        <key>CFBundleIconFiles</key>
        <array>
            <string>AppIcon20x20</string>
            <string>AppIcon29x29</string>
            <string>AppIcon40x40</string>
            <string>AppIcon60x60</string>
        </array>
        <key>UIDeviceFamily</key>
        <array>
            <integer>1</integer>
            <integer>2</integer>
        </array>
        <key>UISupportedInterfaceOrientations</key>
        <array>
            <string>UIInterfaceOrientationPortrait</string>
        </array>
        <key>UIStatusBarStyle</key>
        <string>UIStatusBarStyleDefault</string>
        <key>UIBackgroundModes</key>
        <array>
        </array>
        <key>DTXcode</key>
        <string>0124</string>
        <key>DTXcodeBuild</key>
        <string>12D4e</string>
        <key>DTSDKName</key>
        <string>iphoneos14.4</string>
        <key>DTSDKBuild</key>
        <string>18D46</string>
        <key>DTPlatformName</key>
        <string>iphoneos</string>
        <key>DTCompiler</key>
        <string>com.apple.compilers.llvm.clang.1_0</string>
        <key>DTPlatformVersion</key>
        <string>14.4</string>
        <key>DTPlatformBuild</key>
        <string>18D46</string>
    </dict>
</plist>
XML
  end

  def development_write_info_plist
    log_info "Adding Info.plist."

    info_plist_string = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>NSAppTransportSecurity</key>
        <dict>
                <key>NSAllowsArbitraryLoads</key>
                <true/>
                <key>NSExceptionDomains</key>
                <dict>
                        <key>google.com</key>
                        <dict>
                                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                                <true/>
                                <key>NSIncludesSubdomains</key>
                                <true/>
                        </dict>
                </dict>
        </dict>
        <key>BuildMachineOSBuild</key>
        <string>20D91</string>
        <key>CFBundleDevelopmentRegion</key>
        <string>en</string>
        <key>CFBundleDisplayName</key>
        <string>:app_name</string>
        <key>CFBundleExecutable</key>
        <string>Runtime</string>
        <key>CFBundleIconFiles</key>
        <array>
                <string>AppIcon60x60</string>
        </array>
        <key>CFBundleIcons</key>
        <dict>
                <key>CFBundlePrimaryIcon</key>
                <dict>
                        <key>CFBundleIconFiles</key>
                        <array>
                                <string>AppIcon60x60</string>
                        </array>
                        <key>CFBundleIconName</key>
                        <string>AppIcon</string>
                </dict>
        </dict>
        <key>CFBundleIcons~ipad</key>
        <dict>
                <key>CFBundlePrimaryIcon</key>
                <dict>
                        <key>CFBundleIconFiles</key>
                        <array>
                                <string>AppIcon60x60</string>
                                <string>AppIcon76x76</string>
                                <string>AppIcon83.5x83.5</string>
                        </array>
                        <key>CFBundleIconName</key>
                        <string>AppIcon</string>
                </dict>
        </dict>
        <key>CFBundleIdentifier</key>
        <string>:app_id</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleName</key>
        <string>:app_name</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>5.2</string>
        <key>CFBundleSignature</key>
        <string>????</string>
        <key>CFBundleSupportedPlatforms</key>
        <array>
                <string>iPhoneOS</string>
        </array>
        <key>CFBundleVersion</key>
        <string>5.2</string>
        <key>DTCompiler</key>
        <string>com.apple.compilers.llvm.clang.1_0</string>
        <key>DTPlatformBuild</key>
        <string>18D46</string>
        <key>DTPlatformName</key>
        <string>iphoneos</string>
        <key>DTPlatformVersion</key>
        <string>14.4</string>
        <key>DTSDKBuild</key>
        <string>18D46</string>
        <key>DTSDKName</key>
        <string>iphoneos14.4</string>
        <key>DTXcode</key>
        <string>0124</string>
        <key>DTXcodeBuild</key>
        <string>12D4e</string>
        <key>MinimumOSVersion</key>
        <string>14.4</string>
        <key>UIAppFonts</key>
        <array/>
        <key>UIBackgroundModes</key>
        <array/>
        <key>UIDeviceFamily</key>
        <array>
                <integer>1</integer>
                <integer>2</integer>
        </array>
        <key>UILaunchImages</key>
        <array>
                <dict>
                        <key>UILaunchImageMinimumOSVersion</key>
                        <string>7.0</string>
                        <key>UILaunchImageName</key>
                        <string>Default-568h@2x</string>
                        <key>UILaunchImageOrientation</key>
                        <string>Portrait</string>
                        <key>UILaunchImageSize</key>
                        <string>{320, 568}</string>
                </dict>
                <dict>
                        <key>UILaunchImageMinimumOSVersion</key>
                        <string>7.0</string>
                        <key>UILaunchImageName</key>
                        <string>Default-667h@2x</string>
                        <key>UILaunchImageOrientation</key>
                        <string>Portrait</string>
                        <key>UILaunchImageSize</key>
                        <string>{375, 667}</string>
                </dict>
                <dict>
                        <key>UILaunchImageMinimumOSVersion</key>
                        <string>7.0</string>
                        <key>UILaunchImageName</key>
                        <string>Default-736h@3x</string>
                        <key>UILaunchImageOrientation</key>
                        <string>Portrait</string>
                        <key>UILaunchImageSize</key>
                        <string>{414, 736}</string>
                </dict>
        </array>
        <key>UILaunchStoryboardName</key>
        <string>SimpleSplash</string>
        <key>UIRequiredDeviceCapabilities</key>
        <array>
                <string>arm64</string>
        </array>
        <key>UIRequiresFullScreen</key>
        <true/>
        <key>UIStatusBarStyle</key>
        <string>UIStatusBarStyleDefault</string>
        <key>UISupportedInterfaceOrientations</key>
        <array>
                <string>UIInterfaceOrientationLandscapeRight</string>
        </array>
</dict>
</plist>
XML

    # <string>UIInterfaceOrientationPortrait</string>
    # <string>UIInterfaceOrientationLandscapeRight</string>

    info_plist_string.gsub!(":app_name", @app_name)
    info_plist_string.gsub!(":app_id", @app_id)

    $gtk.write_file_root "tmp/ios/#{@app_name}.app/Info.plist", info_plist_string.strip

    @info_plist_written = true
  end

  def production_write_info_plist
    log_info "Adding Info.plist."

    info_plist_string = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>BuildMachineOSBuild</key>
        <string>20D91</string>
        <key>CFBundleDevelopmentRegion</key>
        <string>en</string>
        <key>CFBundleDisplayName</key>
        <string>:app_name</string>
        <key>CFBundleExecutable</key>
        <string>Runtime</string>
        <key>CFBundleIconFiles</key>
        <array>
                <string>AppIcon60x60</string>
        </array>
        <key>CFBundleIcons</key>
        <dict>
                <key>CFBundlePrimaryIcon</key>
                <dict>
                        <key>CFBundleIconFiles</key>
                        <array>
                                <string>AppIcon60x60</string>
                        </array>
                        <key>CFBundleIconName</key>
                        <string>AppIcon</string>
                </dict>
        </dict>
        <key>CFBundleIcons~ipad</key>
        <dict>
                <key>CFBundlePrimaryIcon</key>
                <dict>
                        <key>CFBundleIconFiles</key>
                        <array>
                                <string>AppIcon60x60</string>
                                <string>AppIcon76x76</string>
                                <string>AppIcon83.5x83.5</string>
                        </array>
                        <key>CFBundleIconName</key>
                        <string>AppIcon</string>
                </dict>
        </dict>
        <key>CFBundleIdentifier</key>
        <string>:app_id</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleName</key>
        <string>:app_name</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>:version</string>
        <key>CFBundleSignature</key>
        <string>????</string>
        <key>CFBundleSupportedPlatforms</key>
        <array>
                <string>iPhoneOS</string>
        </array>
        <key>CFBundleVersion</key>
        <string>:version</string>
        <key>DTCompiler</key>
        <string>com.apple.compilers.llvm.clang.1_0</string>
        <key>DTPlatformBuild</key>
        <string>18D46</string>
        <key>DTPlatformName</key>
        <string>iphoneos</string>
        <key>DTPlatformVersion</key>
        <string>14.4</string>
        <key>DTSDKBuild</key>
        <string>18D46</string>
        <key>DTSDKName</key>
        <string>iphoneos14.4</string>
        <key>DTXcode</key>
        <string>0124</string>
        <key>DTXcodeBuild</key>
        <string>12D4e</string>
        <key>MinimumOSVersion</key>
        <string>14.4</string>
        <key>UIAppFonts</key>
        <array/>
        <key>UIBackgroundModes</key>
        <array/>
        <key>UIDeviceFamily</key>
        <array>
                <integer>1</integer>
                <integer>2</integer>
        </array>
        <key>UILaunchImages</key>
        <array>
                <dict>
                        <key>UILaunchImageMinimumOSVersion</key>
                        <string>7.0</string>
                        <key>UILaunchImageName</key>
                        <string>Default-568h@2x</string>
                        <key>UILaunchImageOrientation</key>
                        <string>Portrait</string>
                        <key>UILaunchImageSize</key>
                        <string>{320, 568}</string>
                </dict>
                <dict>
                        <key>UILaunchImageMinimumOSVersion</key>
                        <string>7.0</string>
                        <key>UILaunchImageName</key>
                        <string>Default-667h@2x</string>
                        <key>UILaunchImageOrientation</key>
                        <string>Portrait</string>
                        <key>UILaunchImageSize</key>
                        <string>{375, 667}</string>
                </dict>
                <dict>
                        <key>UILaunchImageMinimumOSVersion</key>
                        <string>7.0</string>
                        <key>UILaunchImageName</key>
                        <string>Default-736h@3x</string>
                        <key>UILaunchImageOrientation</key>
                        <string>Portrait</string>
                        <key>UILaunchImageSize</key>
                        <string>{414, 736}</string>
                </dict>
        </array>
        <key>UILaunchStoryboardName</key>
        <string>SimpleSplash</string>
        <key>UIRequiredDeviceCapabilities</key>
        <array>
                <string>arm64</string>
        </array>
        <key>UIRequiresFullScreen</key>
        <true/>
        <key>UIStatusBarStyle</key>
        <string>UIStatusBarStyleDefault</string>
        <key>UISupportedInterfaceOrientations</key>
        <array>
                <string>UIInterfaceOrientationLandscapeRight</string>
        </array>
</dict>
</plist>
XML

    # <string>UIInterfaceOrientationPortrait</string>
    # <string>UIInterfaceOrientationLandscapeRight</string>

    info_plist_string.gsub!(":app_name", @app_name)
    info_plist_string.gsub!(":app_id", @app_id)
    info_plist_string.gsub!(":version", @version);

    $gtk.write_file_root "tmp/ios/#{@app_name}.app/Info.plist", info_plist_string.strip

    @info_plist_written = true
  end

  def device_orientation_xml
    return "UIInterfaceOrientationLandscapeRight" if $gtk.logical_width > $gtk.logical_height
    return "UIInterfaceOrientationPortrait"
  end

  def tmp_directory
    "#{relative_path}/tmp/ios"
  end

  def app_path
    "#{tmp_directory}/#{@app_name}.app"
  end

  def root_folder
    "#{relative_path}/#{$gtk.cli_arguments[:dragonruby]}"
  end

  def write_ip_address
    $gtk.write_file "app/server_ip_address.txt", $gtk.ffi_misc.get_local_ip_address.strip
  end

  def create_payload_directory
    sh "cp #{@provisioning_profile_path} \"#{app_path}/embedded.mobileprovision\""
    sh "/usr/bin/plutil -convert binary1 \"#{app_path}/Info.plist\""
    write_ip_address
    sh "rm \"#{@app_name}\".ipa"
    sh "rm -rf \"#{app_path}/app\""
    sh "rm -rf \"#{app_path}/sounds\""
    sh "rm -rf \"#{app_path}/sprites\""
    sh "rm -rf \"#{app_path}/data\""
    sh "rm -rf \"#{app_path}/fonts\""
    sh "cp -r \"#{root_folder}/app/\" \"#{app_path}/app/\""
    sh "cp -r \"#{root_folder}/sounds/\" \"#{app_path}/sounds/\""
    sh "cp -r \"#{root_folder}/sprites/\" \"#{app_path}/sprites/\""
    sh "cp -r \"#{root_folder}/data/\" \"#{app_path}/data/\""
    sh "cp -r \"#{root_folder}/fonts/\" \"#{app_path}/fonts/\""
    sh "mkdir -p #{tmp_directory}/ipa_root/Payload"
    sh "cp -r \"#{app_path}\" \"#{tmp_directory}/ipa_root/Payload\""
    sh "chmod -R 755 \"#{tmp_directory}/ipa_root/Payload\""
  end

  def create_ipa
    do_zip
    sh "cp \"#{tmp_directory}/ipa_root/archive.zip\" \"#{tmp_directory}/#{@app_name}.ipa\""
  end

  def do_zip
    $gtk.write_file_root "tmp/ios/do_zip.sh", <<-SCRIPT
pushd #{tmp_directory}/ipa_root/
zip -q -r archive.zip Payload
popd
SCRIPT

    sh "sh #{tmp_directory}/do_zip.sh"
  end

  def sh cmd
    log_info cmd.strip
    result = `#{cmd}`
    if result.strip.length > 0
      log_info result.strip.each_line.map(&:strip).join("\n")
    end
    result
  end

  def deploy
    sh "XCODE_DIR=\"/Applications/Xcode.app/Contents/Developer\" \"#{relative_path}/dragonruby-deploy-ios\" -d \"#{@device_id}\" \"#{tmp_directory}/#{@app_name}.ipa\""
    log_info "Check your device!!"
  end

  def print_publish_help
      log_info "Go to https://appstoreconnect.apple.com/apps and create an App if you haven't already done so."
      log_info "Go to https://appleid.apple.com and create a 'Application Specific Password'."
      log_info "To upload your app, Download Transporter from the App Store https://apps.apple.com/us/app/transporter/id1450874784?mt=12."
      log_info "Your app is located at ./tmp/ios/#{@app_name}.ipa"
  end

  def compile_icons
    cmd = <<-S
"/Applications/Xcode.app/Contents/Developer/usr/bin/actool" --output-format human-readable-text \
                                                            --notices --warnings --platform iphoneos \
                                                            --minimum-deployment-target 10.3 \
                                                            --target-device iphone \
                                                            --target-device ipad  --app-icon 'AppIcon' \
                                                            --output-partial-info-plist '#{app_path}/AssetCatalog-Info.plist' \
                                                            --compress-pngs --compile "#{app_path}" \
                                                            "#{app_path}/Assets.xcassets"
S
    sh cmd
  end

  def stage_native_libs
    sh "cp -r \"#{root_folder}/native/\" \"#{app_path}/native/\""
    sh "CODESIGN_ALLOCATE=\"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate\" /usr/bin/codesign -f -s \"#{@certificate_name}\" --entitlements #{tmp_directory}/Entitlements.plist \"#{tmp_directory}/#{@app_name}.app/native/ios-device/ext.dylib\""
  end
end
