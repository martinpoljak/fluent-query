Fluent Query
============

**Fluent Query** is cool way how to write SQL queries. Or general way 
how to convert series of method calls to string query in an universal 
and system independent manner. It may sounds like a piece of magic, but 
it works. It's inspired by [Dibi][1].

### General Principle

Some example:

    model.select("[id], [name]").from("[maintainers]").orderBy("[code] ASC")
    
Will be rendered to:

    SELECT `id`, `name` FROM `maintainers` ORDER BY `code` ASC
    
It looks trivial, but for example call `model.heyReturnMeSomething("[yeah]")` 
will be transformed to:

    HEY RETURN ME SOMETHING `yeah`
    
Which gives big potential. Of sure, escaping, aggregation and chaining 
of chunks for example for `WHERE` directive or another is necessary. 
It's ensured by appropriate *language* (e.g. database) *driver*.

And what a more: order of tokens isn't mandatory, so with exception
of initial world (`SELECT`, `INSERT` etc.) you can add them according to
your needs.

### Placeholders

Simple translation calls to queries isn't the only functionality. Very
helpful are also *placeholders*. They works principially by the same way
as `#printf` method, but are more suitable for use in queries and 
supports automatic quoting. Available are:

* `%%s` which quotes string,
* `%%i` which quotes integer,
* `%%b` which quotes boolean,
* `%%f` which quotes float,
* `%%d` which quotes date,
* `%%t` which quotes date-time,

And also three special:

* `%%sql` which quotes subquery (expects query object),
* `%%and` which joins input by `AND` operator (expects hash),
* `%%or` which joins input by `OR` operator (expects hash).

An example:

    model.select("[id], [name]") \
      .from("[maintainers]") \
      .where("[id] = %%i AND company = %%s", 5, "Wikia") \
      .where("[language] IN %%l", ["cz", "en"]) \
      .or \
      .where("[active] IS %%b", true)
      
Will be transformed to:
    
    SELECT `id`, `name` FROM `maintainers` 
        WHERE `id` = 5 
            AND `company` = "Wikia"
            AND `language` IN ("cz", "en")
            OR `active` IS TRUE
            
It's way how to write complex or special queries. But **direct values 
assigning is supported**, so for example:

    model.select(:id, :name) \
      .from(:maintainers) \
      .where(:id => 5, :company => "Wikia") \
      .where("[language] IN %%l", ["cz", "en"])   # %l will join items by commas
      .or \
      .where(:active => true)
      
Will give you expected result too and as you can see, it's much more 
readable, flexible, so preferred.    

### Examples

More examples or tutorials than these above aren't available. It's in 
development, although stable and production ready state. For well 
documented and fully usable application see [Native Query][4].
    

Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b 20101220-my-change`).
3. Commit your changes (`git commit -am "Added something"`).
4. Push to the branch (`git push origin 20101220-my-change`).
5. Create an [Issue][2] with a link to your branch.
6. Enjoy a refreshing Diet Coke and wait.

Copyright
---------

Copyright &copy; 2009-2011 [Martin Kozák][3]. See `LICENSE.txt` for
further details.

[1]: http://dibiphp.com/
[2]: http://github.com/martinkozak/fluent-query/issues
[3]: http://www.martinkozak.net/
[4]: http://github.com/martinkozak/native-query
