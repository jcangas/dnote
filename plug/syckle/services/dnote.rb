module Syckle::Plugins

  # = Developmer's Notes Plugin
  #
  # This plugin goes through you source files and compiles
  # an lit of any labeled comments. Labels are single word
  # prefixes to a comment ending in a colon. For example,
  # you might note somewhere in your code:
  #
  # By default this label supports the TODO, FIXME, OPTIMIZE
  # and DEPRECATE.
  #
  # Output is a set of files in HTML, XML and RDoc's simple
  # markup format. This plugin can run automatically if there
  # is a +notes/+ directory in the project's log directory.
  #
  #--
  # TODO: Should this service be part of the +site+ cycle?
  #++
  class DNote < Service

    cycle :main, :document
    cycle :main, :reset
    cycle :main, :clean

    # not that this is necessary, but ...
    available do |project|
      begin
        require 'dnote/site'
        true
      rescue LoadError
        false
      end
    end

    # autorun if log/notes exists
    autorun do |project|
      (project.log + 'notes').exist?
    end

    # Default note labels to looked for in source code.
    DEFAULT_LABELS = ['TODO', 'FIXME', 'OPTIMIZE', 'DEPRECATE']

    # Paths to search.
    attr_accessor :files

    # Labels to document. Defaults are: TODO, FIXME, OPTIMIZE and DEPRECATE.
    attr_accessor :labels

    # Directory to save output. Defaults to <tt>dnote/</tt> under project
    # log directory.
    attr_accessor :output

    # Formats (xml, html, rdoc).
    attr_accessor :formats

    #
    def output=(path)
      @output = Pathname.new(path)
    end

    #
    def dnote
      @dnote ||= ::DNote::Site.new(files, :labels=>labels, :formats=>formats, :output=>output)
    end

    # Generate notes documents.
    def document
      $NOOP = noop?  # TODO:
      dnote.document
      #mkdir_p(output)
      #file = output + "index.html"
      #File.open(file, 'w'){ |f| f << dnote.to_html }
      report "Updated #{output.to_s.sub(Dir.pwd+'/','')}"
    end

    # Mark notes documents as out-of-date.
    def reset
      #dnote.reset
    end

    # Remove notes directory.
    def clean
      #dnote.clean
    end

  private

    # TODO: maybe files default of **/*.rb is better?
    def initialize_defaults
      @files   = metadata.loadpath || 'lib'
      @output  = project.log + 'dnote'
      @formats = []
      @labels  = DEFAULT_LABELS
    end

  end

end
