module ActionController
  class Base
    before_action :set_raven_context

    def set_raven_context
      Raven.tags_context(request_id: request.uuid) if request
      Raven.user_context(user_uuid: session[:user_uuid]) if session
      Raven.extra_context(params: params.to_unsafe_h) if params
    end
  end
end
