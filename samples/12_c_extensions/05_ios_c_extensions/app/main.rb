# NOTE: This is assumed to be executed with mygame as the root directory
#       you'll need to copy this code over there to try it out.

# Steps:
# 1. Create ext.h and ext.m
# 2. Create Info.plist file
# 3. Add before_create_payload to IOSWizard (which does the following):
#    a. run ./dragonruby-bind against C Extension and update implementation file
#    b. create output location for iOS Framework
#    c. compile C extension into Framework
#    d. copy framework to Payload directory and Sign
# 4. Run $wizards.ios.start env: (:prod|:dev|:hotload) to create ipa
# 5. Invoke args.gtk.dlopen giving the name of the C Extensions (~1s to load).
# 6. Invoke methods as needed.

# ===================================================
# before_create_payload iOS Wizard
# ===================================================
class IOSWizard < Wizard
  def before_create_payload
    puts "* INFO - before_create_payload"

    # invoke ./dragonruby-bind
    sh "./dragonruby-bind --output=mygame/ext-bind.m mygame/ext.h"

    # update generated implementation file
    contents = $gtk.read_file "ext-bind.m"
    contents = contents.gsub("#include \"mygame/ext.h\"", "#include \"mygame/ext.h\"\n#include \"mygame/ext.m\"")
    puts contents

    $gtk.write_file "ext-bind.m", contents

    # create output location
    sh "rm -rf ./mygame/native/ios-device/ext.framework"
    sh "mkdir -p ./mygame/native/ios-device/ext.framework"

    # compile C extension into framework
    sh <<-S
clang -I. -I./mruby/include -I./include -o "./mygame/native/ios-device/ext.framework/ext" \\
      -arch arm64 -dynamiclib -isysroot "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk" \\
      -install_name @rpath/ext.framework/ext \\
      -fembed-bitcode -Xlinker -rpath -Xlinker @loader_path/Frameworks -dead_strip -Xlinker -rpath -fobjc-arc -fobjc-link-runtime \\
      -F/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks \\
      -miphoneos-version-min=10.3 -Wl,-no_pie -licucore -stdlib=libc++ \\
      -framework CFNetwork -framework UIKit -framework Foundation \\
      ./mygame/ext-bind.m
S

    # stage extension
    sh "cp ./mygame/native/ios-device/Info.plist ./mygame/native/ios-device/ext.framework/Info.plist"
    sh "mkdir -p \"#{app_path}/Frameworks/ext.framework/\""
    sh "cp -r \"#{root_folder}/native/ios-device/ext.framework/\" \"#{app_path}/Frameworks/ext.framework/\""

    # sign
    sh <<-S
CODESIGN_ALLOCATE=#{codesign_allocate_path} #{codesign_path} \\
                                            -f -s \"#{certificate_name}\" \\
                                            \"#{app_path}/Frameworks/ext.framework/ext\"
S
  end
end

def tick args
  if args.state.tick_count == 60 && args.gtk.platform?(:ios)
    args.gtk.dlopen 'ext'
    include FFI::CExt
    puts "the results of hello world are:"
    puts hello_world()
    $gtk.console.show
  end
end
