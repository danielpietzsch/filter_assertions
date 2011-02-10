# filter_assertions plugin for Rails

This plugin extends the class `ActionController::TestCase` by adding assertions to test if before filters have been applied (via `before_filter` or `append_before_filter`) or skipped (via `skip_before_filter`).

These assertions are added for use in your functional tests:

 * `assert_before_filter`: use this to test your `before_filter` or `append_before_filter` statements.
 * `assert_no_before_filter`: use this to test your `skip_before_filter` statements.
 * `assert_forgery_protection`: use this to test your `protect_from_forgery` statements.

## Examples
	
	# Test if the before_filter :authenticate applies to all actions in the controller
	assert_before_filter :authenticate
	
	# Test if the filter only applies to actions 'index' and 'new'
	assert_before_filter :authenticate, :only => [:index, :new]
	
	# Test if the filter applies to all actions axcept 'index'
	assert_before_filter :authenticate, :except => :index
	
The `assert_no_before_filter` assertion takes the same options and the `assert_forgery_protection` *only takes the `:except` or `:only` options*.

There are different ways to test for the same functionality:

	# These two assertion are equivalent
	assert_before_filter :authenticate, :except => :index
	assert_no_before_filter :authenticate, :only => :index

## How it works

The assertions of this plugin do not test for functionality of your before\_filters. It looks for the specified filters in the controller's filter\_chain and checks if the filters are applied or skipped for the specified actions.  
That means you can even check for before\_filters when you usually skip them in your functional tests.

## Why would I want to test for before_filters like that?

It's usually a good idea to test your controllers *including* its before\_filters and create different tests for when a before_filter applies and for when it doesn't.  
But there might be cases when you can't do this easily. Maybe there's an external dependency a filter relies on - such as an external service or app for authentication for example. With this plugin, you could skip all before\_filters for your tests and still be able to test if they would normally apply (deployed on a server for example).

However - as said before - this plugin does not test any functionality of the filters themselves. The assertions only check if the filters apply to all actions or a subset of actions of the controller you are testing.

## TODO

Make this plugin work with Rails 3 (it has only been tested with Rails 2.3 so far).
	
## Credits

This plugin is based on the idea and code described in this blog post by S M Sohan: [Unit/Functional Test Rails ActionController filters following DRY](http://smsohan.blogspot.com/2009/05/unit-test-actioncontroller-filters.html "Sohan - on software artisanship: Unit/Functional Test Rails ActionController filters following DRY").

Copyright (c) 2011 Daniel Pietzsch, released under the MIT license