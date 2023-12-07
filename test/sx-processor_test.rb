# frozen_string_literal: true

require 'test_helper'

class SxProcessorTest < Minitest::Test
  def setup
    @processor = SxProcessor.new
    @template1 = <<~SLIM
      - if items.any?
        table id=items class='table yellow'
        - for item in items
          tr
            td.name = item.name
            td.price = item.price
      - else
        p 'No items found.'
    SLIM

    @template2 = <<~SLIM
      ruby:
        print_value = true

      - if print_value
        p = 'Hello World'.capitalize
    SLIM
  end

  def test_process_template1
    result = @processor.process_template(@template1)
    expected_result1 = <<~RUBY
      if items.any?
      #{'       '}
        for item in items
      #{'      '}
                item.name
                item.price
      else
           'No items found.'
    RUBY
    assert_equal expected_result1, result
  end

  def test_process_template2
    result = @processor.process_template(@template2)
    expected_result2 = <<~RUBY

      print_value = true

      if print_value
           'Hello World'.capitalize
    RUBY
    assert_equal expected_result2, result
  end
end
