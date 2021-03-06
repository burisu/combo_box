module ComboBox
  module ActionController

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
    end
    
    module ClassMethods


      # Generates a default action which is the resource for a combo_box.
      # It generates an helper which takes in account selected columns for displaying.
      # The label used to display items is based on the used columns. These columns can be
      # used with I18n. The key used is: +views.combo_boxes.<controller>.<action>+
      # 
      # @macro [new] options_details
      #   @param [Hash] options Options to build controller action
      #   @option options [Array] :columns The columns which are used for search and display
      #     All the content columns are used by default.
      #     A column can be a Symbol/String with its name or Hash with keys (+:name+,
      #     +:filter+, +:interpolation_key+)
      #   @option options [Array,Hash] :conditions Default conditions used in the search query
      #   @option options [String, Hash, Array] :joins To make a join like in +find+
      #   @option options [Integer] :limit (80) Maximum count of items in results
      #   @option options [String] :partial Specify a partial for HTML autocompleter
      #   @option options [String] :filter ('%X%') Filter format used to build search query. 
      #     Specific filters can be specified for each column. 
      #
      # @overload search_for(name, model, options={})
      #   Defines a controller method +search_for_NAME+ which searches for records
      #   of the class +MODEL+.
      #   @param [Symbol] name Name of the datasource
      #   @param [String, Symbol] name Name of the model to use for searching
      #   @macro options_details
      #
      # @overload search_for(name, options={})
      #   Defines a controller method +search_for_NAME+ which searches for records
      #   of the class +NAME+.
      #   @param [Symbol] name
      #     Name of the datasource. This name is used to find the model name
      #   @macro options_details
      #
      # @overload search_for(options={})
      #   Defines a controller method +search_for+ which searches for records corresponding to the
      #   resource controller name. +OrdersController#search_for+ searches for orders.
      #   @macro options_details
      #
      # @example Search clients with Person model
      #   # app/controller/orders_controller.rb
      #   class OrdersController < ApplicationController
      #     ...
      #     search_for :clients, :person
      #     ...
      #   end
      # 
      # @example Search all accounts where name contains search and number starts with search
      #   # app/controller/orders_controller.rb
      #   class PeopleController < ApplicationController
      #     ...
      #     search_for :accounts, :columns=>[:name, 'number:X%']
      #     ...
      #   end
      #   
      # @example Search for orders among all others
      #   # app/controller/orders_controller.rb
      #   class OrdersController < ApplicationController
      #     ...
      #     search_for
      #     ...
      #   end
      def search_for(*args)
        options = args.delete_at(-1) if args[-1].is_a? Hash
        name, model = args[0], args[1]
        action_name = "#{__method__}#{'_'+name.to_s if name}"
        model = model || name || controller_name
        if [String, Symbol].include?(model.class)
          model = model.to_s.classify.constantize             
        end
        return unless model.table_exists?
        generator = Generator::Base.new(self, action_name, model, options)
        class_eval(generator.controller_action, "#{__FILE__}:#{__LINE__}")
        # ActionView::Base.send(:class_eval, generator.view_code, "#{__FILE__}:#{__LINE__}")
        ComboBox::CompiledLabels.send(:class_eval, generator.item_label_code, "#{__FILE__}:#{__LINE__}")
      end

    end

  end
end
