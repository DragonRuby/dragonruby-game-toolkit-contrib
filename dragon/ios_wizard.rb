# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# ios_wizard.rb has been released under MIT (*only this file*).

# Contributors outside of DragonRuby who also hold Copyright: Michał Dudziński

class IOSWizard < Wizard
  def initialize
    @doctor_executed_at = 0
  end

  def relative_path
    (File.dirname $gtk.binary_path)
  end

  def steps
    @steps ||= []
  end

  def prerequisite_steps
    [
      :check_for_xcode,
      :check_for_brew,
      :check_for_certs,
    ]
  end

  def app_metadata_retrieval_steps
    [
      :determine_team_identifier,
      :determine_app_name,
      :determine_app_id,
    ]
  end

  def steps_development_build
    [
      *prerequisite_steps,

      :check_for_device,
      :check_for_dev_profile,

      *app_metadata_retrieval_steps,
      :determine_devcert,

      :clear_tmp_directory,
      :stage_app,

      :development_write_info_plist,

      :write_entitlements_plist,
      :compile_icons,
      :clear_payload_directory,

      :create_payload_directory_dev,

      :create_payload,
      :code_sign_payload,

      :create_ipa,
      :deploy
    ]
  end

  def steps_production_build
    [
      *prerequisite_steps,

      :check_for_distribution_profile,
      :determine_app_version,

      *app_metadata_retrieval_steps,
      :determine_prodcert,

      :clear_tmp_directory,
      :stage_app,

      :production_write_info_plist,

      :write_entitlements_plist,
      :compile_icons,
      :clear_payload_directory,

      :create_payload_directory_prod,

      :create_payload,
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

  def start opts = nil
    @opts = opts || {}

    if !(@opts.is_a? Hash) || !($gtk.args.fn.eq_any? @opts[:env], :dev, :prod)
      raise WizardException.new(
              "* $wizards.ios.start needs to be provided an environment option.",
              "** For development builds type: $wizards.ios.start env: :dev",
              "** For production builds type: $wizards.ios.start env: :prod"
            )
    end

    @production_build = (@opts[:env] == :prod)
    @steps = steps_development_build
    @steps = steps_production_build if @production_build
    @certificate_name = nil
    @app_version = opts[:version]
    @app_version = "1.0" if @opts[:env] == :dev && !@app_version
    init_wizard_status
    log_info "Starting iOS Wizard so we can deploy to your device."
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
      log e.__backtrace_to_org__
    end

    init_wizard_status
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

  def ios_metadata_template
    <<-S
# ios_metadata.txt is used by the Pro version of DragonRuby Game Toolkit to create iOS apps.
# Information about the Pro version can be found at: http://dragonruby.org/toolkit/game#purchase

# teamid needs to be set to your assigned Team Id which can be found at https://developer.apple.com/account/#/membership/
teamid=
# appid needs to be set to your application identifier which can be found at https://developer.apple.com/account/resources/identifiers/list
appid=
# appname is the name you want to show up underneath the app icon on the device. Keep it under 10 characters.
appname=
# devcert is the certificate to use for development/deploying to your local device
devcert=
# prodcert is the certificate to use for distribution to the app store
prodcert=
S
  end

  def ios_metadata
    contents = $gtk.read_file 'metadata/ios_metadata.txt'

    if !contents
      $gtk.write_file 'metadata/ios_metadata.txt', ios_metadata_template
      contents = $gtk.read_file 'metadata/ios_metadata.txt'
    end

    kvps = contents.each_line
                   .reject { |l| l.strip.length == 0 || (l.strip.start_with? "#") }
                   .map do |l|
                     key, value = l.split("=")
                     [key.strip.to_sym, value.strip]
                   end.flatten
    Hash[*kvps]
  end

  def game_metadata
    contents = $gtk.read_file 'metadata/game_metadata.txt'

    kvps = contents.each_line
                   .reject { |l| l.strip.length == 0 || (l.strip.start_with? "#") }
                   .map do |l|
                     key, value = l.split("=")
                     [key.strip.to_sym, value.strip]
                   end.flatten
    Hash[*kvps]
  end

  def raise_ios_metadata_required
    raise WizardException.new(
            "* mygame/metadata/ios_metadata.txt needs to be filled out.",
            "You need to update metadata/ios_metadata.txt with a valid teamid, appname, appid, devcert, and prodcert.",
            "Instructions for where the values should come from are within metadata/ios_metadata.txt."
          )
  end

  def determine_team_identifier
    @team_id = (ios_metadata.teamid || "")
    raise_ios_metadata_required if @team_id.strip.length == 0
    log_info "Team Identifer is: #{@team_id}"
  end

  def determine_app_name
    @app_name = (ios_metadata.appname || "")
    raise_ios_metadata_required if @app_name.strip.length == 0
    log_info "App name is: #{@app_name}."
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

  def determine_app_id
    @app_id = ios_metadata.appid
    raise_ios_metadata_required if @app_id.strip.length == 0
    log_info "App Identifier is set to: #{@app_id}"
  end

  def determine_devcert
    @certificate_name = ios_metadata.devcert
    raise_ios_metadata_required if @certificate_name.strip.length == 0
    log_info "Dev Certificate is set to: #{@certificate_name}"
  end

  def determine_prodcert
    @certificate_name = ios_metadata.prodcert
    raise_ios_metadata_required if @certificate_name.strip.length == 0
    log_info "Production (Distribution) Certificate is set to: #{@certificate_name}"
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

  def clear_tmp_directory
    sh "rm -rf #{tmp_directory}"
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

    if @production_build
      @certificate_name = ios_metadata[:prodcert]
    else
      @certificate_name = ios_metadata[:devcert]
    end

    log_info "I will be using certificate: '#{@certificate_name}'."
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

    $gtk.write_file_root "tmp/ios/Entitlements.plist", entitlement_plist_string.gsub(":app_id", "#{@team_id}.#{@app_id}").strip
    $gtk.write_file_root "tmp/ios/Entitlements.txt", entitlement_plist_string.gsub(":app_id", "#{@team_id}.#{@app_id}").strip

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
        <string>:app_version</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>:app_version</string>
        <key>CFBundleSignature</key>
        <string>????</string>
        <key>CFBundleVersion</key>
        <string>:app_version</string>
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
        <string>:app_version</string>
        <key>CFBundleName</key>
        <string>:app_name</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>:app_version</string>
        <key>CFBundleSignature</key>
        <string>????</string>
        <key>CFBundleSupportedPlatforms</key>
        <array>
                <string>iPhoneOS</string>
        </array>
        <key>CFBundleVersion</key>
        <string>:app_version</string>
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
    $gtk.write_file_root "tmp/ios/Info.txt", info_plist_string.strip

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
        <string>:app_version</string>
        <key>CFBundleName</key>
        <string>:app_name</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>:app_version</string>
        <key>CFBundleSignature</key>
        <string>????</string>
        <key>CFBundleSupportedPlatforms</key>
        <array>
                <string>iPhoneOS</string>
        </array>
        <key>CFBundleVersion</key>
        <string>:app_version</string>
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
    info_plist_string.gsub!(":app_version", @app_version)

    $gtk.write_file_root "tmp/ios/#{@app_name}.app/Info.plist", info_plist_string.strip
    $gtk.write_file_root "tmp/ios/Info.txt", info_plist_string.strip

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

  def embed_mobileprovision
    sh %Q[cp #{@provisioning_profile_path} "#{app_path}/embedded.mobileprovision"]
    sh %Q[/usr/bin/plutil -convert binary1 "#{app_path}/Info.plist"]
  end

  def clear_payload_directory
    sh %Q[rm "#{@app_name}".ipa]
    sh %Q[rm -rf "#{app_path}/app"]
    sh %Q[rm -rf "#{app_path}/sounds"]
    sh %Q[rm -rf "#{app_path}/sprites"]
    sh %Q[rm -rf "#{app_path}/data"]
    sh %Q[rm -rf "#{app_path}/fonts"]
  end

  def stage_app
    log_info "Staging."
    sh "mkdir -p #{tmp_directory}"
    sh "cp -R #{relative_path}/dragonruby-ios.app \"#{tmp_directory}/#{@app_name}.app\""
    sh %Q[cp -r "#{root_folder}/app/" "#{app_path}/app/"]
    sh %Q[cp -r "#{root_folder}/sounds/" "#{app_path}/sounds/"]
    sh %Q[cp -r "#{root_folder}/sprites/" "#{app_path}/sprites/"]
    sh %Q[cp -r "#{root_folder}/data/" "#{app_path}/data/"]
    sh %Q[cp -r "#{root_folder}/fonts/" "#{app_path}/fonts/"]
  end

  def create_payload
    sh %Q[mkdir -p #{tmp_directory}/ipa_root/Payload]
    sh %Q[cp -r "#{app_path}" "#{tmp_directory}/ipa_root/Payload"]
    sh %Q[chmod -R 755 "#{tmp_directory}/ipa_root/Payload"]
  end

  def create_payload_directory_dev
    # write dev machine's ip address for hotloading
    $gtk.write_file "app/server_ip_address.txt", $gtk.ffi_misc.get_local_ip_address.strip

    embed_mobileprovision
    clear_payload_directory
    stage_app
  end

  def create_payload_directory_prod
    # production builds does not hotload ip address
    sh %Q[rm "#{root_folder}/app/server_ip_address.txt"]

    embed_mobileprovision
    stage_app

    # production build marker
    sh %Q[mkdir -p "#{app_path}/metadata/"]
    sh %Q[touch metadata/DRAGONRUBY_PRODUCTION_BUILD]
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
    has_transporter = (sh "ls /Applications/Transporter.app").include? "Contents"
    if !has_transporter
      $gtk.openurl "https://apps.apple.com/us/app/transporter/id1450874784?mt=12"
      $console.set_command "$wizards.ios.start env: :#{@opts[:env]}, version: \"#{@opts[:version]}\""
      raise WizardException.new(
        "* To upload your app, Download Transporter from the App Store https://apps.apple.com/us/app/transporter/id1450874784?mt=12."
      )
    else
      sh "mkdir ./tmp/ios/intermediary_artifacts"
      sh "mv \"#{tmp_directory}/#{@app_name}.app\" #{tmp_directory}/intermediary_artifacts/"
      sh "mv \"#{tmp_directory}/do_zip.sh\" #{tmp_directory}/intermediary_artifacts"
      sh "mv \"#{tmp_directory}/Entitlements.plist\" #{tmp_directory}/intermediary_artifacts"
      sh "mv \"#{tmp_directory}/ipa_root\" #{tmp_directory}/intermediary_artifacts/"
      sh "open /Applications/Transporter.app"
      sh "open ./tmp/ios/"
    end
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

  def set_version version
    @app_version = version
    start env: @opts[:env], version: version
  end

  def app_version
    log_info "Attempting to retrieve App Version from metadata/ios_metadata.txt."
    ios_version_number = (ios_metadata.version || "").strip
    if ios_version_number.length == 0
      log_info "Not found. Attempting to retrieve App Version from metadata/game_metadata.txt."
      ios_version_number = (game_metadata.version || "").strip
    end
    ios_version_number
  end

  def determine_app_version
    @app_version = app_version
    return if @app_version
  end
end
