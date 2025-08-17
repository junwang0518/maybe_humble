module Maybe
  class << self
    def version
      Semver.new(semver)
    end

    def commit_sha
      if Rails.env.production? || ENV["BUILD_COMMIT_SHA"].present?
        ENV["BUILD_COMMIT_SHA"]
      else
        begin
          `git rev-parse HEAD`.chomp
        rescue Errno::ENOENT
          "unknown"
        end
      end
    end

    private
      def semver
        "0.6.0"
      end
  end
end
