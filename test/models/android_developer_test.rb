require 'test_helper'

class AndroidDeveloperTest < ActiveSupport::TestCase
  def setup
    @developer = AndroidDeveloper.create!(
      name: 'MS development Co',
      identifier: 'MS+Co'
    )
    @website = Website.create!(
      url: 'https://www.mightysignal.com/en',
      match_string: 'mightysignal.com/en',
      domain: 'mightysignal.com'
    )
  end

  def test_json_format
    res = @developer.api_json
    assert_instance_of String, res[:name]
    assert_equal :android, res[:platform]
    assert_instance_of Array, res[:websites]
    assert_instance_of Array, res[:details]
  end

  test 'short json format excludes websites and details' do
    res = @developer.api_json(short_form: true)
    assert_instance_of String, res[:name]
    assert_equal :android, res[:platform]
    assert_nil res[:websites]
    assert_nil res[:details]
  end

  test 'finds developer by domain' do
    x = AndroidDevelopersWebsite.create!(
      android_developer_id: @developer.id,
      website_id: @website.id,
      is_valid: true
    )
    x.update!(is_valid: true) # override activerecord callback
    res = AndroidDeveloper.find_by_domain('mightysignal.com')
    assert_equal 1, res.count
    assert_equal @developer.identifier, res.first.identifier
  end

  test 'finds developer by domain ignoring flagged associations' do
    x = AndroidDevelopersWebsite.create!(
      android_developer_id: @developer.id,
      website_id: @website.id,
      is_valid: false
    )
    x.update!(is_valid: false) # override activerecord callback
    res = AndroidDeveloper.find_by_domain('mightysignal.com')
    assert_equal 0, res.count
  end
end
