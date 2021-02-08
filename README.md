# Exception Notifier

This is GiveLively's exception notification wrapper. The goal of this gem is to provide the charity api with a clean set of exception and logging apis regardless of what exception client is used under the hood. 

Currently we use [sentry-raven](https://www.rubydoc.info/gems/sentry-raven/2.7.3), which is now in maintenance mode. it is recommended by Sentry that we migrate from this deprecated sdk to the newer [sentry-ruby](https://docs.sentry.io/platforms/ruby/). `ExceptionNotifier` will isolate the main charity api app from this change.

## Usage

`ExceptionNotifier` supports the following:

**Record an Exception**

Capture exceptions with the call method. 
```ruby
  begin
    Raise StandardError
  rescue StandardError => error
    ExceptionNotifier.call(error)
  end
```

**Adding Context**

The `add_context` method takes two arguments, first a `type` which must be symbol: `:tags_context`, `:user_context`, or `:extra_context`. Second, a `Hash` of parameters to add to the given context type.
```ruby
# add tags to the context
ExceptionNotifier.add_context(:tags_context, my_tag: my_tag_value)

# add user info to the context
ExceptionNotifier.add_context(:user_context, user_id: user_id)

# add extra info to the context
ExceptionNotifier.add_context(:extra_context, more_info: { interesting_data: 1234, more_data: 'hello world' })
```

**Add Breadcrumbs to Context**

The `breadcrumbs` method takes two arguments, first a `message` which must be a `String`, and second a `Hash` of data to add to the context's breadcrumb trail.
```ruby
ExceptionNotifier.breadcrumbs(message: 'foo', data: { bar: 'baz' })
```

**Breadcrumb Inspection**

For testing purposes, we may wish to inspect the last  `breadcrumb`. To do so, we provide a `last_breadcrumb` method.

```ruby
# spec/...
describe '#method' do
  let(:breadcrumb) { ExceptionNotifier.last_breadcrumb }

  it 'adds correct message' do
    expect(breadcrumb.message).to eq expected_message
  end

  it 'adds correct data' do
    expect(breadcrumb.data).to eq expected_data
  end
end
```