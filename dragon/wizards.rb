# Copyright 2019 DragonRuby LLC
# MIT License
# wizards.rb has been released under MIT (*only this file*).

module GTK
  class Wizards
    attr_accessor :ios, :itch

    def initialize
      @ios = IOSWizard.new
      @itch = ItchWizard.new
    end
  end
end
