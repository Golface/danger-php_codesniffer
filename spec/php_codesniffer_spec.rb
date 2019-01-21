require File.expand_path("../spec_helper", __FILE__)
require 'json'

module Danger
  describe Danger::DangerPhpCodesniffer do
    it "should be a plugin" do
      expect(Danger::DangerPhpCodesniffer.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @php_codesniffer = @dangerfile.php_codesniffer
      end

      before do
        gitlab = Danger::RequestSources::GitLab.new({}, testing_env)
        allow(@dangerfile).to receive(:gitlab).and_return gitlab
        allow(@dangerfile).to receive(:github)
      end

      it "raises error if phpcs is not installed" do
        allow(@php_codesniffer).to receive(:phpcs_path).and_return(nil)
        expect { @php_codesniffer.exec }.to raise_error("phpcs is not installed")
      end

      describe :exec do
        before do
          @mix_result = JSON.parse File.read('spec/fixtures/result/multiple.json')
          @error_result = JSON.parse File.read('spec/fixtures/result/error.json')
          @warning_result = JSON.parse File.read('spec/fixtures/result/warning.json')
          @empty_result = JSON.parse File.read('spec/fixtures/result/empty.json')

          allow(@php_codesniffer).to receive(:run_phpcs)
                                         .with("phpcs", "spec/fixtures/php/error.php")
                                         .and_return @error_result
          allow(@php_codesniffer).to receive(:run_phpcs)
                                         .with("phpcs", "spec/fixtures/php/warning.php")
                                         .and_return @warning_result
          allow(@php_codesniffer).to receive(:run_phpcs)
                                         .with("phpcs", "spec/fixtures/php/empty.php")
                                         .and_return @empty_result
        end

        before do
          allow(@php_codesniffer).to receive(:phpcs_path).and_return "phpcs"

        end

        it "checks all PHP files when filtering is not set" do
          allow(@php_codesniffer).to receive(:run_phpcs).and_return @mix_result
          @php_codesniffer.exec
          output = @php_codesniffer.status_report[:markdowns]

          expect(output.length).to eq(4)
          expect(output[0].message).to eq("# PHP_CodeSniffer report")
          expect(output[1].message).to eq("## There are 3 errors, 1 warnings and 4 fixable in the MR")
          expect(output[2].message).to include("application/config/autoload.php")
          expect(output[3].message).to include("application/config/hooks.php")
        end

        describe "when filtering is true" do
          before do
            @php_codesniffer.filtering = true
          end

        end

        it "checks PHP files with only modified_files" do
          allow(@php_codesniffer.git).to receive(:modified_files)
            .and_return(["spec/fixtures/php/error.php"])
          allow(@php_codesniffer.git).to receive(:deleted_files)
            .and_return([])
          allow(@php_codesniffer.git).to receive(:added_files)
            .and_return([])
          allow(@php_codesniffer).to receive(:phpcs_path).and_return "phpcs"

          @php_codesniffer.filtering = true
          @php_codesniffer.exec

          output = @php_codesniffer.status_report[:markdowns]

          expect(output.length).to eq 3
          expect(output[0].message).to eq("# PHP_CodeSniffer report")
          expect(output[1].message).to eq("## There are 1 errors, 0 warnings and 1 fixable in the MR")
          expect(output[2].message).to include("spec/fixtures/php/error.php")
        end

        it "checks PHP files without deleted files and with modified and added files" do
          allow(@php_codesniffer.git).to receive(:modified_files)
                                             .and_return(["spec/fixtures/php/error.php"])
          allow(@php_codesniffer.git).to receive(:deleted_files)
                                             .and_return(["spec/fixtures/php/empty.php"])
          allow(@php_codesniffer.git).to receive(:added_files)
                                             .and_return(["spec/fixtures/php/warning.php"])
          allow(@php_codesniffer).to receive(:phpcs_path).and_return "phpcs"


          @php_codesniffer.filtering = true
          @php_codesniffer.exec

          output = @php_codesniffer.status_report[:markdowns]

          expect(output.length).to eq 4
          expect(output[0].message).to eq("# PHP_CodeSniffer report")
          expect(output[1].message).to eq("## There are 1 errors, 1 warnings and 2 fixable in the MR")
          expect(output[2].message).to include("spec/fixtures/php/error.php")
        end
      end
    end
  end
end
