# frozen_string_literal: true

class ExceptionNotifier
  CONTEXT_TYPES = %i(extra_context tags_context user_context)
  class << self
    def call(*args)
      if exceptionable?(args.first)
        capture_exception(args)
      else
        capture_message(args)
      end
    end

    def capture_exception(args)
      error_client.capture_exception(*args)
    end

    def capture_message(args)
      if args.first.is_a?(String)
        message = args.first
        extra = args.length == 2 && args.last.is_a?(Hash) ? args.last : { parameters: args.drop(1) }
      else
        message = 'Unknown parameter set.'
        extra = { parameters: args }
      end

      error_client.capture_message(message, extra: extra)
    end

    def exceptionable?(obj)
      obj.is_a?(Exception) ||
        (obj.respond_to?(:ancestors) && obj.ancestors.include?(Exception))
    end

    # @parmas type [Symbol] the type of context to add, either `:tags_context`, `:user_context`, or `:extra_context`
    # @params context [Hash] the key values to add as context
    def add_context(type, context)
      raise ArgumentError.new('type paramater must be one of: :extra_context, :tags_context, :user_context') unless CONTEXT_TYPES.include?(type)
      raise ArgumentError.new('contexts must be a hash') unless context.is_a?(Hash)

      case type
      when :user_context
        error_client.set_user(context)
      when :tags_context
        error_client.set_tags(context)
      when :extra_context
        error_client.set_extras(context)
      end
    end

    # @params data [Hash] the key values to add to the breadcrumb
    # @params message [String] the message string to add to the breadcrumb
    def breadcrumbs(data:, message: nil)
      raise ArgumentError.new('data must be a hash') unless data.is_a?(Hash)
      raise ArgumentError.new('when providing a message, it must be a string') if message.present? && !message.is_a?(String)

      crumb = breadcrumb.new(message: message, data: data)
      error_client.add_breadcrumb(crumb)
    end

    def last_breadcrumb
      error_client.get_current_scope&.breadcrumbs&.peek
    end

    private

    def error_client
      Sentry
    end

    def breadcrumb
      error_client::Breadcrumb
    end
  end
end
