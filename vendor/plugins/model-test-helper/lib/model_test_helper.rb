module ModelTestHelper
   def self.included(base)
      base.class_eval do
         def self.model_name
            # strip Test suffix off name
            self.name[0, self.name.length-4]
         end

         def self.model_data_name
            "#{model_name}TestModelData"
         end

         def self.model_data
            model_data_name.constantize
         end

         def self.model
            model_name.constantize
         end

         def model
            self.class.model
         end

         def create(params = self.class.attributes_for_new)
            model.new(params)
         end

         def self.attributes_for_new
           begin
             self.model_data.attributes_for_new
           rescue NameError
             nil
           end || (raise "Define attributes_for_new class method or define a class #{self.model_data_name} with an attributes_for_new class method.")
         end

         def self.unique_attributes
           begin
             self.model_data.unique_attributes
           rescue NameError
             nil
           end || []
         end

         def self.non_null_attributes
           begin
             self.model_data.non_null_attributes
           rescue NameError
             nil
           end || []
         end

         def self.bad_attributes
           begin
             self.model_data.bad_attributes
           rescue NameError
             nil
           end || []
         end

         def self.str_length_attributes
           begin
             self.model_data.str_length_attributes
           rescue NameError
             nil
           end || []
         end

         def self.perform_basic_model_tests(options = {})
           skip = options[:skip] ? options[:skip] : []
           self.perform_new_test unless skip.include?(:new)
           self.perform_fixtures_correct_size_test unless skip.include?(:fixtures_correct_size)
           self.perform_destroy_test unless skip.include?(:destroy)
           self.perform_all_models_valid_test unless skip.include?(:all_models_valid)
           self.perform_non_null_attributes_test unless skip.include?(:non_null_attributes)
           self.perform_unique_attributes_test unless skip.include?(:unique_attributes)
           self.perform_bad_attributes_test unless skip.include?(:bad_attributes)
           self.perform_str_length_attributes_test unless skip.include?(:str_length_attributes)
         end

         def self.perform_all_models_valid_test
           define_method(:test_all_models_valid) do
             model.find(:all).each do |value|
               if not value.valid?
                 fail( "Invalid #{self.class.model_name} loaded #{value.id}.\n#{value.to_xml}\nErrors:\n#{value.errors.to_xml}" )
               end
             end
           end
         end

         def self.perform_new_test
           define_method(:test_new) do
             attr = self.class.attributes_for_new
             value = model.new
             attr.each_pair {|k,v| value.send("#{k}=".to_sym,v)}
             if not value.valid?
                fail( "Invalid #{model.name} created #{value.id}.\n#{value.to_xml}\nErrors:\n#{value.errors.to_xml}" )
             end
             attr.each do |name|
                assert_equal(attr[name], value.attributes[name], "Attribute value @#{name.to_s} incorrect")
             end
           end
         end

         def self.perform_fixtures_correct_size_test
           define_method(:test_fixtures_correct_size) do
             expected = model.find(:first, :select => 'id', :group => 'id HAVING id = max(id)', :order => 'id DESC').id
             actual = model.count
             assert_equal(expected, actual, "Expected to have #{expected} fixtures as that is the max id. Actual value #{actual}.")
           end
         end

         def self.perform_destroy_test
           define_method(:test_destroy) do
             values = model.find(:all)
             values.each do |v|
                model.destroy(v.id) if model.exists?(v.id)
                assert_equal(false, model.exists?(v.id), "Unable to destroy #{v.id}.")
             end
           end
         end

         def self.perform_non_null_attributes_test
            self.non_null_attributes.each do |f|
              define_method("test_#{f}_present".to_sym) do
                attr = self.class.attributes_for_new
                attr.delete(f)
                value = model.new(attr)
                assert_equal(false, value.valid?)
                assert_not_nil(value.errors[f])
              end
            end
         end

         def self.perform_str_length_attributes_test
            self.str_length_attributes.each do |f|
               name = f[0]
               length = f[1]
               define_method("test_#{name}_too_long".to_sym) do
                 attr = self.class.attributes_for_new
                 value = model.new(attr)
                 value.send "#{name}=".to_sym, ('X'*(length+1))
                 assert_equal(false, value.valid?)
                 assert_not_nil(value.errors[name])
               end
            end
         end

         def self.perform_unique_attributes_test
            self.unique_attributes.each do |f|
               name = f.is_a?(Array) ? f.join('_and_') : f.to_s
               string = ""
               vals = f.is_a?(Array) ? f : [f]
               define_method("test_#{name}_unique".to_sym) do
                 other = model.find(:first)
                 attr = self.class.attributes_for_new
                 vals.each do |v|
                    attr[v] = other.send v
                 end
                 value = model.new(attr)
                 assert_equal(false, value.valid?)
                 if vals.length == 1
                    assert_not_nil(value.errors[vals[0]])
                 end
               end
            end
         end

         def self.perform_bad_attributes_test
            self.bad_attributes.each do |f|
               key = f[0]
               value = f[1]
               configuration = {:description => 'invalid', :message => nil}.merge((f.length == 3) ? f[2] : {})

               define_method("test_#{configuration[:description]}_#{key}".to_sym) do
                 attr = self.class.attributes_for_new.merge(key => value)
                 value = model.new(attr)
                 assert_equal(false, value.valid?)
                 assert_not_nil(value.errors[key])
                 assert_equal(configuration[:message],value.errors[key]) if configuration[:message]
               end
            end
         end
      end
   end
end
