# FilterAssertions plugin for Rails

This plugin extends the class `ActionController::TestCase` by adding assertions to test if before filters have been applied (via `before_filter` or `append_before_filter`) or skipped (via `skip_before_filter`).

These assertions are added for use in your functional tests:

 * `assert_before_filter`
 * `assert_no_before_filter`
 * `assert_forgery_protection`

Use `assert_before_filter` to test your `before_filter` or `append_before_filter` statements.  
Use `assert_no_before_filter` to test your `skip_before_filter` statements.  
Use `assert_forgery_protection` to test your `protect_from_forgery` statements.

## Examples
	
	# Test if the before_filter :authenticate applies to all actions in the controller
	assert_before_filter :authenticate
	
	# Test if the filter only applies to certain actions
	assert_before_filter(:authenticate, :only => [:index, :new])
	
	# Test if the filter
	assert_before_filter(:authenticate, :except => :index)


Copyright (c) 2011 Daniel Pietzsch, released under the MIT license
