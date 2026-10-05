#!/usr/bin/env ruby
# Настраивает macOS Xcode-проект Runner:
# - добавляет GoogleService-Info.plist в bundle
# - выставляет DEVELOPMENT_TEAM и CODE_SIGN_IDENTITY
# Идемпотентный. Запускать из корня Flutter-проекта.

require 'xcodeproj'

PROJECT_PATH = 'macos/Runner.xcodeproj'
TARGET_NAME = 'Runner'
GOOGLE_SERVICE_FILE = 'macos/Runner/GoogleService-Info.plist'
GOOGLE_SERVICE_REF_PATH = 'Runner/GoogleService-Info.plist'
TEAM_ID = '4WG9VZ2A3N'
CODE_SIGN_IDENTITY = 'Apple Development'

project = Xcodeproj::Project.open(PROJECT_PATH)

# 1. Добавить GoogleService-Info.plist к target Runner (если ещё не добавлен)
runner_target = project.targets.find { |t| t.name == TARGET_NAME }
raise "Target #{TARGET_NAME} не найден" unless runner_target

runner_group = project.main_group.find_subpath('Runner', false)
raise 'Runner group не найдена' unless runner_group

existing = runner_group.files.find { |f| f.path == 'GoogleService-Info.plist' }
if existing.nil?
  file_ref = runner_group.new_reference('GoogleService-Info.plist')
  file_ref.last_known_file_type = 'text.plist.xml'
  runner_target.resources_build_phase.add_file_reference(file_ref, true)
  puts "Added GoogleService-Info.plist to #{TARGET_NAME}"
else
  # Убедимся, что он в resources build phase
  in_resources = runner_target.resources_build_phase.files_references.include?(existing)
  unless in_resources
    runner_target.resources_build_phase.add_file_reference(existing, true)
    puts "Added existing GoogleService-Info.plist to resources build phase"
  else
    puts "GoogleService-Info.plist already referenced"
  end
end

# 2. Signing settings на все configurations Runner
runner_target.build_configurations.each do |config|
  config.build_settings['DEVELOPMENT_TEAM'] = TEAM_ID
  config.build_settings['CODE_SIGN_IDENTITY'] = CODE_SIGN_IDENTITY
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  # Убираем PROVISIONING_PROFILE_SPECIFIER, если пуст, — не мешает.
  puts "Configured signing for #{TARGET_NAME}/#{config.name}"
end

project.save
puts 'Saved project.pbxproj'
