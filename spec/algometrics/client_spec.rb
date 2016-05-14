require 'spec_helper'

describe Algometrics::Client do
  let(:stubs)   { Faraday::Adapter::Test::Stubs.new }
  let(:api_key) { 'abc' }
  let(:url)     { 'http://test' }
  let(:client)  { described_class.new(url: url, api_key: api_key) }
  let(:faraday) { Faraday.new { |f| f.adapter(:test, stubs) } }

  before { allow_any_instance_of(described_class).to receive(:connection).and_return(faraday) }

  describe '#parse_actor' do
    context 'when hash given' do
      subject { client.send(:parse_actor, type: 'abc', id: '123') }
      it { should eq(type: 'abc', id: '123') }
    end

    context 'when string given' do
      subject { client.send(:parse_actor, 'abc#123') }
      it { should eq(type: 'abc', id: '123') }
    end
  end

  describe '#validate_actor_string' do
    it 'should return true for valid string' do
      expect(client.send(:validate_actor_string, 'abc_123#456abc')).to eq true
    end

    it 'should return false for invalid string' do
      expect(client.send(:validate_actor_string, 'abc.123#asd')).to eq false
      expect(client.send(:validate_actor_string, 'abc')).to eq false
    end
  end

  describe '#validate_actor_hash' do
    it 'should return true for valid hash' do
      expect(client.send(:validate_actor_hash, type: 'abc_123', id: 'qwe_123')).to eq true
    end

    it 'should return false for invalid hash' do
      expect(client.send(:validate_actor_hash, {})).to eq false
      expect(client.send(:validate_actor_hash, type: '123#', id: 'sad')).to eq false
      expect(client.send(:validate_actor_hash, type: '123', id: 'x.y')).to eq false
    end
  end

  describe '#valid_actor?' do
    context 'when given hash' do
      context 'with valid actor' do
        subject { client.send(:valid_actor?, type: 'abc', id: '123') }
        it { should be true }
      end

      context 'with invalid actor' do
        subject { client.send(:valid_actor?, type: 'abc.', id: '#123') }
        it { should be false }
      end
    end

    context 'when given string' do
      context 'with valid actor' do
        subject { client.send(:valid_actor?, 'abc#123') }
        it { should be true }
      end

      context 'with invalid actor' do
        subject { client.send(:valid_actor?, 'abc.##123') }
        it { should be false }
      end
    end
  end

  describe '#user_agent' do
    subject { client.user_agent }

    it { should eq "algometrics-gem #{Algometrics::VERSION}" }
  end

  describe '#track' do
    before { stubs.post("#{client.api_version}/events") { [202, {}, ''] } }

    it 'should send event with given data' do
      event_name = 'TestEvent'
      actor = { type: 'User', id: '1' }

      expected_data = {
        event: event_name,
        actor: actor,
        status: Algometrics::SUCCESS
      }.to_json

      expect(client.connection).to receive(:post).with("#{client.api_version}/events", expected_data)
      client.track(event: event_name, actor: 'User#1')
    end
  end
end
