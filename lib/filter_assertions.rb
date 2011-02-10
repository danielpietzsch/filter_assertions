# FilterAssertions

# Extends the ActionController::TestCase class.
# Adds assertions to test if a before_filter is applied or skipped
class ActionController::TestCase
  # This method is the matching assertion to the before_filter or append_before_filter methods
  #
  # Examples:
  # - assert_before_filter :authenticate, :only => [:index, :new]
  # - assert_before_filter :authenticate, :except => :index
  def assert_before_filter(before_filter_name, options = {})
    filter = find_matching_before_filter(before_filter_name)

    raise NameError, "Couldn't find filter '#{before_filter_name}'" if filter.nil?
  
    if options.blank?
      # When the filter's options are empty, it means the filter applies to all controller methods.
      assert filter.options.empty?, "The filter #{before_filter_name} has only/except options and does not apply to all actions."
    else
      # The Array() cast makes sure that if you only enter one action without brackets
      # (instead of listing multiple actions), that it's converted to an Array
      # and can be processed with the code below
      actions_only   = Array(options[:only])
      actions_except = Array(options[:except])
    
      raise ArgumentError, "Unrecognised options. Valid options: :only and :except" if actions_only.blank? && actions_except.blank?
      
      assert_block "The filter '#{before_filter_name}' does NOT apply to all the actions specified." do
        filter_only_applies_to_actions?(filter, actions_only)
      end if actions_only.present?
      
      assert_block "The filter '#{before_filter_name}' applies to more actions than specified." do
        filter_is_excepted_from_actions?(filter, actions_except)
      end if actions_except.present?   
    end    
  end

  # This method is the matching assertion to the skip_before_filter method
  #
  # Examples:
  # - assert_no_before_filter :authenticate, :only => [:index, :new]
  # - assert_no_before_filter :authenticate, :except => :index
  def assert_no_before_filter(before_filter_name, options = {})
    filter = find_matching_before_filter(before_filter_name)
  
    if options.blank?
      # if the options are blank no filter should have been found, because it is then skipped for all actions
      assert filter.nil?, "The filter #{before_filter_name} has only/except options and is not skipped for all actions."
    else
      # The Array() cast makes sure that if you only enter one action without brackets
      # (instead of listing multiple actions), that it's converted to an Array
      # and can be processed with the code below
      actions_only   = Array(options[:only])
      actions_except = Array(options[:except])
    
      raise ArgumentError, "Unrecognised options. Valid options are :only and :except" if actions_only.blank? && actions_except.blank?
      
      assert_block "The filter '#{before_filter_name}' is NOT skipped for all the actions specified." do
        filter_is_excepted_from_actions?(filter, actions_only)
      end if actions_only.present?
      
      assert_block "The filter '#{before_filter_name}' is skipped for more actions than specified." do
        filter_only_applies_to_actions?(filter, actions_except)
      end if actions_except.present?
    end
  end

  # The protect_from_forgery method is just a wrapper for
  # another before_filter. And so are these assertion methods
  # just a wrapper for the assert_before_filter method.
  def assert_forgery_protection(options = {})
    assert_before_filter(:verify_authenticity_token, options)    
  end

  #########################
  private
  #########################

  # Returns the BeforeFilter object matching before_filter_name or nil
  # OPTIMIZE make this more elegant
  def find_matching_before_filter(before_filter_name)
    @controller.class.filter_chain().each do |filter|
      return filter if filter.is_a?(ActionController::Filters::BeforeFilter) && filter.method == before_filter_name
    end
  
    nil
  end
  
  def filter_only_applies_to_actions?(filter, actions)
    all_actions_without_supplied_ones = get_all_controller_actions.reject { |action| actions.include?(action.to_sym) }
    
    filter_applies_to_all_actions?(filter, actions) && filter_is_skipped_for_all_actions?(filter, all_actions_without_supplied_ones)
  end
  
  def filter_is_excepted_from_actions?(filter, actions)
    all_actions_without_supplied_ones = get_all_controller_actions.reject { |action| actions.include?(action.to_sym) }
    
    filter_is_skipped_for_all_actions?(filter, actions) && filter_applies_to_all_actions?(filter, all_actions_without_supplied_ones)
  end
  
  def filter_applies_to_all_actions?(filter, actions)
    actions.all? { |action| before_filter_applied?(filter, action) }
  end
  
  def filter_is_skipped_for_all_actions?(filter, actions)
    actions.all? { |action| !before_filter_applied?(filter, action) }
  end
  
  # Checks if the given filter is applied to the given action
  def before_filter_applied?(filter, action)
    return false if filter.nil? || action.nil?
  
    # if it is a skip_before_filter
    if filter.options[:skip].present?
      return filter.options[:skip][:except].include?(action.to_s) if filter.options[:skip][:except].present?
      return !filter.options[:skip][:only].include?(action.to_s) if filter.options[:skip][:only].present? 
    else
      return true if filter.options.empty? # because then a normal filter would be applied to all actions
      return !filter.options[:except].include?(action.to_s) if filter.options[:except].present?
      return filter.options[:only].include?(action.to_s) if filter.options[:only].present?
    end
  end
  
  def get_all_controller_actions
    # Idea taken from this blogpost:
    # http://blog.wolfman.com/articles/2007/7/28/rspec-testing-all-actions-of-a-controller
    klass = Module.const_get(@controller.class.to_s)
    klass.public_instance_methods(false)
  end
end # of class ActionController::TestCase