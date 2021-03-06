class FormField < ActiveRecord::Base
  include Cache
  has_many :form_field_validations, -> { order "form_field_validation_memberships.validation_order" }, :through => :form_field_validation_memberships
  has_many :form_field_validation_memberships
  has_many :form_field_groups, :through => :form_field_memberships
  has_many :form_field_memberships
  has_many :validations

  def options_group
    cache_fetch('options_group' + self.options_group_id.to_s,'never') do
      OptionsGroup.where(:group_id => self.options_group_id)
    end
  end

  def get_options_group_values
    cache_fetch('options_group_values_' + self.options_group_id.to_s,'never') do
      OptionsGroup.where(:group_id => self.options_group_id).pluck(:value)
    end
  end

  def validate(value)
    errors = {}
    self.form_field_validations.map{ |validate| 
      if !(val=validate.test(value)).nil? 
        errors[name] = val
      end
    }
    errors
  end
end
