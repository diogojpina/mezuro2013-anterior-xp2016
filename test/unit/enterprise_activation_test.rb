require File.dirname(__FILE__) + '/../test_helper'

class EnterpriseActivationTest < ActiveSupport::TestCase

  fixtures :users, :profiles

  should 'be a Task' do
    assert_kind_of Task, EnterpriseActivation.new
  end

  should 'keep enterprise_id' do
    assert_nil EnterpriseActivation.new.enterprise_id
  end

  should 'have an enteprise through enterprise_id' do
    ent = Enterprise.create!(:name => 'my enterprise', :identifier => 'myent')

    assert_equal ent, EnterpriseActivation.new(:enterprise_id => ent.id).enterprise
  end

  should 'require an enterprise' do
    t = EnterpriseActivation.new
    t.valid?
    assert t.errors.invalid?(:enterprise_id), "enterprise must be required"

    ent = Enterprise.create!(:name => 'my enterprise', :identifier => 'myent')
    t.enterprise = ent
    t.valid?
    assert !t.errors.invalid?(:enterprise_id), "must validate after enterprise is set"
  end

  should 'activate enterprise when finished' do
    ent = Enterprise.create!(:name => 'my enterprise', :identifier => 'myent', :enabled => false)
    t = EnterpriseActivation.create!(:enterprise => ent)
    t.requestor = profiles(:ze)

    t.finish
    ent.reload

    assert ent.enabled, "finishing task should left enterprise enabled"
  end

  should 'require requestor to finish' do
    ent = Enterprise.create!(:name => 'my enterprise', :identifier => 'myent', :enabled => false)
    t = EnterpriseActivation.create!(:enterprise => ent)

    assert_raise EnterpriseActivation::RequestorRequired do
      t.finish
    end
  end

  should 'put requestor as enterprise owner when finishing' do
    ent = Enterprise.create!(:name => 'my enterprise', :identifier => 'myent', :enabled => false)
    t = EnterpriseActivation.create!(:enterprise => ent)

    person = profiles(:ze)
    t.requestor = person

    t.stubs(:enterprise).returns(ent)

    # must pass the requestor to the enterprise activation
    ent.expects(:enable).with(person)

    t.finish
  end

  should 'have target notification description' do
    ent = fast_create(Enterprise, :enabled => false)
    task = EnterpriseActivation.create!(:enterprise => ent, :requestor => profiles(:ze))

   assert_match(/#{task.requestor.name} wants to activate enterprise #{ent.name}/, task.target_notification_description)
  end

end

