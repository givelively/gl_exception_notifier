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

    it 'correctly reports mixed parameters to Sentry' do
      allow(Raven).to receive(:capture_message)

      Raven.should_receive(:capture_message).with(
        'message', extra: [{ details: 'we are in trouble' }]
      )
      described_class.call('message', details: 'we are in trouble')
    end
  end
end
