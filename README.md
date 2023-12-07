# SxProcessor

SxProcessor is a Ruby class that processes SLIM templates and converts them into Ruby code. It interprets the symbolic expression (sxp) structure of a SLIM template and translates it into appropriately formatted and indented Ruby code.

## Usage

```slim
  - if items.any?
    table id=items class='table yellow'
    - for item in items
      tr
        td.name = item.name
        td.price = item.price
    - else
      p 'No items found.'
```
The above SLIM template is processed to the following Ruby code:
```rb
 if items.any?
       
   for item in items
       
           item.name
           item.price
 else
     'No items found.'
```

# Testing
Tests are written using Minitest. To run the tests, navigate to the project directory in your terminal and run:
```sh
ruby -Ilib -Itest test/sx-processor_test.rb
```

## License

This code is licensed under the terms of the MIT license. See the [LICENSE.md](LICENSE.md) file for details.
