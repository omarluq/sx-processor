# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
require 'slim'
require 'pry'

# The SxProcessor class processes SLIM templates and converts them into Ruby code.
# It interprets the symbolic expression (sxp) structure of a SLIM template and
# translates it into appropriately formatted and indented Ruby code.
#
# == Example Usage:
#
#   processor = SxProcessor.new
#   slim_template = <<~SLIM
#     - if items.any?
#       table id=items class='table yellow'
#       - for item in items
#         tr
#           td.name = item.name
#           td.price = item.price
#       - else
#         p 'No items found.'
#     SLIM
#   ruby_code = processor.process_template(slim_template)
#   puts ruby_code
#
# The above SLIM template would be processed to the following Ruby code:
#
#  if items.any?
#
#    for item in items
#
#            item.name
#            item.price
#  else
#      'No items found.'
#
# == SLIM SXP and Node Types:
# SLIM templates are parsed into a nested array structure called symbolic expression (sxp).
# Each element of the array represents a different type of node in the SLIM template, such as:
# - :multi - A container node that holds a sequence of other nodes.
# - :slim - Nodes representing SLIM-specific logic like control structures (:control), embedded Ruby (:embedded), etc.
# - :html - Nodes representing HTML elements in the template.
# - :newline - Represents a newline in the template for formatting.
#
class SxProcessor
  extend T::Sig

  sig { void }
  def initialize
    @indent_space_cache = T.let({}, T::Hash[Integer, String])
  end

  # Processes a SLIM template and converts it into Ruby code.
  # @param slim_template String The SLIM template to process.
  # @return [String] The formatted Ruby code.
  sig { params(slim_template: String).returns(String) }
  def process_template(slim_template)
    sxp = Slim::Parser.new.call(slim_template)
    process(sxp)
  end

  private

  sig { params(sxp: T::Array[T.untyped], indent: Integer, is_root: T::Boolean).returns(String) }
  def process(sxp, indent = 0, is_root = true)
    sxp.map do |node|
      next unless node.is_a?(Array)

      process_node(node, indent, is_root)
    end.compact.join
  end

  sig { params(node: T::Array[T.untyped], indent: Integer, is_root: T::Boolean).returns(T.nilable(String)) }
  def process_node(node, indent, is_root)
    case node.first
    when :multi
      process(node[1..], indent, is_root)
    when :slim
      process_slim(node, indent, is_root)
    when :html
      process_html(node, indent)
    when :newline
      "\n"
    end
  end

  sig { params(node: T::Array[T.untyped], indent: Integer, is_root: T::Boolean).returns(T.nilable(String)) }
  def process_slim(node, indent, is_root)
    case node[1]
    when :embedded
      process(node[3], is_root ? 0 : indent + 1, false)
    when :interpolate, :control, :output
      [indent_space(indent) + node[2].strip,
       (process(node[3], indent + 1, false) if node.length > 3)].compact.join
    end
  end

  sig { params(node: T::Array[T.untyped], indent: Integer).returns(T.nilable(String)) }
  def process_html(node, indent)
    extra_whitespaces = convert_html_to_whitespaces(node)
    result = [(indent_space(indent) + extra_whitespaces if extra_whitespaces)]
    if node[4].is_a?(Array)
      result << (node[4][0] == :slim ? slim_html_content(node, indent) : process(node[4], indent, false))
    end
    result.compact.join
  end

  sig { params(node: T::Array[T.untyped], indent: Integer).returns(String) }
  def slim_html_content(node, indent)
    case node[4][1]
    when :output, :interpolate
      index = node[4][1] == :output ? 3 : 2
      "#{indent_space(indent)}#{node[4][index].strip}\n"
    else
      process(node[4], indent, false)
    end
  end

  sig { params(indent: Integer).returns(String) }
  def indent_space(indent)
    @indent_space_cache[indent] ||= '  ' * indent
  end

  sig { params(html_node: T::Array[T.untyped]).returns(String) }
  def convert_html_to_whitespaces(html_node)
    case html_node[1]
    when :tag
      ' ' * html_node[2].to_s.length
    when :attrs
      html_node[2..].reduce(' ') do |whitespaces, attr_node|
        attr_format = attr_node[3][0]
        subindex = attr_format == :static ? 1 : 3
        whitespaces + (' ' * (attr_node[2].length + attr_node[3][subindex].to_s.length))
      end
    else
      ''
    end
  end
end

# Example usage with sample templates and writing to files
# processor = SxProcessor.new
# template1 = <<~SLIM
#   - if items.any?
#     table id=items class='table yellow'
#     - for item in items
#       tr
#         td.name = item.name
#         td.price = item.price
#   - else
#     p 'No items found.'
# SLIM

# template2 = <<~SLIM
#   ruby:
#     print_value = true

#   - if print_value
#     p = 'Hello World'.capitalize
# SLIM

# File.write('example1.rb', processor.process_template(template1))
# File.write('example2.rb', processor.process_template(template2))
