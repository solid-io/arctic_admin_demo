# frozen_string_literal: true

require "test_helper"
class CompanyTest < ActiveSupport::TestCase
  def setup
    @company = companies(:example_company)
  end

  context "associations" do
    should have_one_attached(:logo)
    should have_many(:locations)
    should have_many(:admin_user_companies)
    should have_many(:admin_users).through(:admin_user_companies)
    should accept_nested_attributes_for(:locations)
  end

  context "validations" do
    should validate_presence_of(:name)
    should validate_presence_of(:description)
    should validate_presence_of(:subdomain)
    should validate_presence_of(:domain)
  end

  context "database_columns" do
    should have_db_column(:name)
    should have_db_column(:description)
    should have_db_column(:subdomain)
    should have_db_column(:domain)
    should have_db_column(:created_at)
    should have_db_column(:updated_at)
  end

  test "location has_location? method" do
    assert(@company.methods.include?(:has_locations?))
  end

  test "company.has_location? returns boolean" do
    assert_includes([true, false], @company.has_locations?)
  end
end
