require 'sentry-ruby'
require 'gl_exception_notifier'
require 'active_support/all'

describe GLExceptionNotifier do
  let(:client) { Sentry }

  describe 'call' do
    context 'with an exception as parameter' do
      it 'accepts Exceptions as parameter' do
        allow(client).to receive(:capture_exception)

        expect(described_class).to receive(:capture_exception)
        described_class.call(ZeroDivisionError)
      end
    end

    context 'with a form of message as parameters' do
      it 'accepts Arrays as parameter' do
        expect(described_class).to receive(:capture_message)
        described_class.call(%w[we are in trouble])
      end

      it 'accepts Hashes as parameter' do
        expect(described_class).to receive(:capture_message)
        described_class.call(message: 'we are in trouble')
      end

      it 'accepts mixed parameters' do
        expect(described_class).to receive(:capture_message)
        described_class.call('message', details: 'we are in trouble')
      end

      it 'correctly reports a message with a hash of params to Sentry' do
        expect(client).to receive(:capture_message)
                      .with('message', extra: { details: 'we are in trouble' })

        described_class.call('message', details: 'we are in trouble')
      end

      it 'correctly reports a message with an array of params to Sentry' do
        expect(client).to receive(:capture_message)
                      .with('message', extra: { parameters: [1, 2, 3] })
        described_class.call('message', 1, 2, 3)
      end
    end

    context 'with keyword args' do
      let(:target_message) { 'GLExceptionNotifier: called with kwargs, should have been positional' }

      it 'calls with the unknown params' do
        expect(client).to receive(:capture_message).with(target_message,
                                                         extra: { parameters: [{ error: 'Something' }] })

        described_class.call(error: 'Something')
      end
    end
  end

  describe '.add_context' do
    context 'when extra context' do
      let(:params) { { params: { a: 1, b: 2 } } }

      before { allow(client).to receive(:set_extras) }

      it 'sets extra context' do
        expect(client).to receive(:set_extras).with(params)
        described_class.add_context(:extra_context, params)
      end
    end

    context 'when tags context' do
      let(:request_id) { 'abcd12345' }

      before { allow(client).to receive(:set_extras) }

      it 'sets extra context' do
        expect(client).to receive(:set_tags).with({ request_id: })

        described_class.add_context(:tags_context, request_id:)
      end
    end

    context 'when user context' do
      let(:uuid) { 'abcd12345' }

      before { allow(client).to receive(:set_user) }

      it 'sets user context' do
        expect(client).to receive(:set_user).with({ user_uuid: uuid })
        described_class.add_context(:user_context, user_uuid: uuid)
      end
    end

    context 'when invalid type' do
      it 'raises argument error' do
        expect { described_class.add_context(:foo_context, id: 'abcde12345') }.to raise_error ArgumentError
      end
    end

    context 'when invalid context' do
      it 'raises argument error' do
        expect { described_class.add_context(:user_context, 'abcde12345') }.to raise_error ArgumentError
      end
    end
  end

  describe '.breadcrumb' do
    let(:data) { { a: 1 } }
    let(:message) { 'message' }
    let(:breadcrumbs) { instance_double('breadcrumbs') } # rubocop:disable RSpec/VerifiedDoubleReference

    before do
      allow(client).to receive(:get_current_scope).and_return(breadcrumbs)
      allow(breadcrumbs).to receive(:record).with(kind_of(client::Breadcrumb))
    end

    it 'sets message and data crumbs' do
      expect(client).to receive(:add_breadcrumb)
                    .with(having_attributes(data:, message:))
      described_class.breadcrumbs(data:, message:)
    end

    context 'when data is invalid' do
      it 'raises argument error' do
        expect { described_class.breadcrumbs(data: message, message:) }.to raise_error ArgumentError
      end
    end

    context 'when message is invalid' do
      it 'raises argument error' do
        expect { described_class.breadcrumbs(data:, message: data) }.to raise_error ArgumentError
      end
    end

    context 'when message is not provided' do
      it 'sets data cumbs' do
        expect(client).to receive(:add_breadcrumb)
        result = described_class.breadcrumbs(data:)
        expect(result.data).to eq(data)
        expect(result.message).to be_blank
      end

      it 'creates a breadcrumb' do
        expect(client).to receive(:add_breadcrumb)
                      .with(instance_of(Sentry::Breadcrumb))
        described_class.breadcrumbs(data:)
      end
    end
  end

  describe '.last_breadcrumb' do
    let(:breadcrumbs) { instance_double('breadcrumb') } # rubocop:disable RSpec/VerifiedDoubleReference
    let(:scope) { instance_double('scope') } # rubocop:disable RSpec/VerifiedDoubleReference

    before do
      allow(client).to receive(:get_current_scope).and_return(scope)
      allow(scope).to receive(:breadcrumbs).and_return(breadcrumbs)
    end

    it 'returns the last crumb from the buffer' do
      expect(breadcrumbs).to receive(:peek)
      described_class.last_breadcrumb
    end
  end
end
