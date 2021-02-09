require 'raven'
require 'exception_notifier'

describe ExceptionNotifier do
  context 'with an exception as parameter' do
    it 'accepts Exceptions as parameter' do
      allow(Raven).to receive(:capture_exception)

      described_class.should_receive(:capture_exception)
      described_class.call(ZeroDivisionError)
    end
  end

  context 'with a form of message as parameters' do
    it 'accepts Arrays as parameter' do
      allow(Raven).to receive(:capture_message)

      described_class.should_receive(:capture_message)
      described_class.call(%w[we are in trouble])
    end

    it 'accepts Hashes as parameter' do
      allow(Raven).to receive(:capture_message)

      described_class.should_receive(:capture_message)
      described_class.call(message: 'we are in trouble')
    end

    it 'accepts mixed parameters' do
      allow(Raven).to receive(:capture_message)

      described_class.should_receive(:capture_message)
      described_class.call('message', details: 'we are in trouble')
    end

    it 'correctly reports a message with a hash of params to Sentry' do
      allow(Raven).to receive(:capture_message)

      Raven.should_receive(:capture_message).with(
        'message', extra: { details: 'we are in trouble' }
      )
      described_class.call('message', details: 'we are in trouble')
    end

    it 'correctly reports a message with an array of params to Sentry' do
      allow(Raven).to receive(:capture_message)

      Raven.should_receive(:capture_message).with('message', extra: { parameters: [1, 2, 3] })
      described_class.call('message', 1, 2, 3)
    end
  end

  describe '.add_context' do
    context 'when extra context' do
      let(:params) { { params: { a: 1, b: 2 } } }

      before { allow(Raven).to receive(:extra_context) }

      it 'sets extra context' do
        Raven.should_receive(:extra_context).with(params)
        described_class.add_context(:extra_context, params)
      end
    end

    context 'when tags context' do
      let(:request_id) { 'abcd12345' }

      before { allow(Raven).to receive(:extra_context) }

      it 'sets extra context' do
        Raven.should_receive(:tags_context).with(request_id: request_id)
        described_class.add_context(:tags_context, request_id: request_id)
      end
    end

    context 'when user context' do
      let(:uuid) { 'abcd12345' }

      before { allow(Raven).to receive(:user_context) }

      it 'sets user context' do
        Raven.should_receive(:user_context).with(user_uuid: uuid)
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
    let(:breadcrumbs) { instance_double('breadcrumb') }
    let(:crumb) { instance_double('crumb') }
    let(:data) { { a: 1 } }
    let(:message) { 'message' }

    before do
      allow(Raven).to receive(:breadcrumbs).and_return(breadcrumbs)
      allow(breadcrumbs).to receive(:record).and_yield(crumb)
      allow(crumb).to receive(:message=).with(message)
      allow(crumb).to receive(:data=).with(data)
    end

    it 'sets message and data crumbs' do
      crumb.should_receive(:message=).with(message)
      crumb.should_receive(:data=).with(data)

      described_class.breadcrumbs(data: data, message: message)
    end

    context 'when data is invalid' do
      it 'raises argument error' do
        expect { described_class.breadcrumbs(data: message, message: message) }.to raise_error ArgumentError
      end
    end

    context 'when message is invalid' do
      it 'raises argument error' do
        expect { described_class.breadcrumbs(data: data, message: data) }.to raise_error ArgumentError
      end
    end

    context 'when message is not provided' do
      it 'sets data cumbs' do
        crumb.should_receive(:message=).never
        crumb.should_receive(:data=).with(data)

        described_class.breadcrumbs(data: data)
      end
    end
  end

  describe '.last_breadcrumb' do
    let(:breadcrumbs) { instance_double('breadcrumb') }
    let(:buffer) { ['first', 'last'] }

    before do
      allow(Raven).to receive(:breadcrumbs).and_return(breadcrumbs)
      allow(breadcrumbs).to receive(:buffer).and_return(buffer)
    end

    it 'returns the last crumb from the buffer' do
      expect(described_class.last_breadcrumb).to eq 'last'
    end
  end
end
