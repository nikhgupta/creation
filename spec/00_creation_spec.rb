require 'spec_helper'

describe Creation do
  it 'has a version number' do
    expect(Creation::VERSION).not_to be nil
  end

  context "with help command" do
    it 'brands itself' do
      help = %x(#{creation_binary})

      expect(help).to include("creation new APP_PATH")
      expect(help).to include("creation new ~/Code/Ruby/weblog")
      expect($?).to eq(0)
    end

    it 'describes options for skipping customizations' do
      help = %x(#{creation_binary})

      expect(help).to include("--no-no-creation")
      expect(help).to include("--admin-namespace=ADMIN_NAMESPACE")

      # TODO: populate this automatically?
      %w[active-admin bootstrap pundit test-suite flat-ui sidekiq home-page].each do |feat|
        expect(help).to match(/\[--skip-#{feat}\], \[--no-skip-#{feat}\]\s+\# Skip/)
      end
    end
  end
end
