require 'rails_helper'

describe Ad do
  specify do
    expect(Ad < ApplicationRecord).to eql(true)
  end

  describe 'generating keys for secure message_type' do
    let(:ad) { build(:ad, :secure) }

    specify do
      expect(ad.secret_key).to be_blank
      ad.valid?
      secret_before_persisted = ad.secret_key
      public_before_persisted = ad.public_key
      expect(ad.secret_key).to be_present
      expect(ad.public_key).to be_present
      ad.save
      expect(ad.secret_key).to be_present
      expect(ad.reload.secret_key).to eql(secret_before_persisted)
      expect(ad.reload.public_key).to eql(public_before_persisted)
    end
  end

  describe '#as_json' do
    subject { ad.as_json }

    context 'when secure ad' do
      let(:ad) { create(:ad, :secure) }
      
      it { is_expected.to_not have_key(:secret_key) }
      it { is_expected.to_not have_key(:public_key) }

      specify do
        expect(subject['base64_public_key']).to eql(Base64.encode64(ad.public_key))
      end
    end

    context 'when direct ad' do
      let(:ad) { create(:ad) }

      it { is_expected.to_not have_key(:secret_key) }
      it { is_expected.to_not have_key(:public_key) }
      
      specify do
        expect(subject['base64_public_key']).to be_blank
      end
    end
  end
end
