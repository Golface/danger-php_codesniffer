require "json"

module Danger
  # Checks PHP files code standard using [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer).
  #
  # @example Execute PHP_CodeSniffer with changed files only and ignored directory
  #
  #          php_codesniffer.ignore = "./vendor"
  #          php_codesniffer.filtering = true
  #          php_codesniffer.exec
  #
  # @see  golface/danger-php_codesniffer
  # @tags monday, weekends, time, rattata
  #
  class DangerPhpCodesniffer < Plugin

    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [String]
    attr_accessor :ignore

    # Enable filtering
    # Only show messages within changed files.
    # @return [Boolean]
    attr_accessor :filtering

    # Execute and process phpcs CLL's result.
    #
    # @return [void]
    def exec
      bin = phpcs_path
      raise "phpcs is not installed" unless bin

      summary = { "errors"=> 0, "warnings"=> 0, "fixable"=> 0 }
      report = []

      unless filtering
        result = run_phpcs(bin, ".")
        summary = result.fetch("totals")
        report = generate_report result
      else
        ((git.modified_files - git.deleted_files) + git.added_files)
          .select {|file| ((file.end_with? ".php") || (file.end_with? ".inc"))}
          .map { |file| file.gsub("#{Dir.pwd}/", '') }
          .each do |file|
            result = run_phpcs(bin, file)
            totals = result.fetch("totals")

            summary["errors"] += totals["errors"]
            summary["warnings"] += totals.fetch("warnings")
            summary["fixable"] += totals.fetch("fixable")

            report.push(generate_report result)
          end
      end

      markdown "# PHP_CodeSniffer report"
      markdown generate_summary_markdown summary
      markdown report
    end

    private

    # Get phpcs' bin path
    #
    # @return [String]
    def phpcs_path
      path = "./vendor/bin/phpcs"
      File.exist?(path) ? path : find_executable("phpcs")
    end

    # Execute phpcs CLI and return the the result in JSON object
    #
    # @return [Hash]
    def run_phpcs(bin, file)
      command = "#{bin} --report=json "
      command << "--basepath=. "
      command << "--ignore=#{ignore}" if ignore
      result = `#{command} #{file}`
      JSON.parse result
    end

    # Generate summary markdown text
    #
    # @param  [Hash] summary
    #         The report summary, default: errors, warnings and fixable are 0
    # @return [String]
    def generate_summary_markdown(summary = { errors: 0, warnings: 0, fixable: 0 })
      request_type = host_type == :gitlab ? "MR" : "PR"
      "## There are #{summary["errors"]} errors, #{summary["warnings"]} warnings and #{summary["fixable"]} fixable in the #{request_type}"
    end

    # Generate phpcs report markdown text by each file
    #
    # @param [Hash] result
    #         The phpcs result
    # @return [Array<String>]
    def generate_report(result)
      report = []

      result.fetch("files")
        .each do |file_name, v|
          tbody = v.fetch("messages")
            .map do |item|
              # puts item
              emoji = item.fetch("type") == "ERROR" ? ":no_entry_sign:" : ":warning:"
              "<tr><td>#{emoji}</td><td>At line #{item.fetch("line")}</td><td>#{item.fetch("message")}</td></tr>"
            end
            .join("\n")

          line = "<details><summary>#{file_name}</summary>"
          line << "<table><thead><tr><th>Type</th><th>line</th><th>message</th></tr></thead>"
          line << "<tbody>#{tbody}</tbody></table></details>"

          report.push line
        end

      report
    end

    # Get SCM host_type
    #
    # return [Symbol]
    def host_type
      scm = :other
      if defined? @dangerfile.gitlab
        scm = :gitlab

      elsif defined? @dangerfile.github
        scm = :github

      end

      scm
    end

  end
end
