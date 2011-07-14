Fluent Query
============

**Fluent Query** is cool way how to write SQL queries. And general way 
how to convert series of method calls to string query in an universal 
and system independent manner. It may sounds like a piece of magic, but 
it works. It's inspired by [Dibi][1].


### General Principle

Some example:

    connection.select("[id], [name]").from("[maintainers]").orderBy("[code] ASC")
    
Will be rendered to:

    SELECT `id`, `name` FROM `maintainers` ORDER BY `code` ASC
    
It looks trivial, but for example call `connection.heyReturnMeSomething("[yeah]")` 
will be transformed to:

    HEY RETURN ME SOMETHING `yeah`
    
Which gives big potential. Of sure, escaping, aggregation and chaining 
of chunks for example for `WHERE` directive or another is necessary. 
It's ensured by appropriate *language* (e.g. database) *driver*.

And what a more: order of tokens isn't mandatory, so with exception
of initial world (`SELECT`, `INSERT` etc.) you can add them according to
your needs.

### Connecting

    # Include it!
    require "fluent-query/mysql"
    require "fluent-query"
    
    # Setup it!
    driver = FluentQuery::Drivers::MySQL
    settings = {
        :username => "wikistatistics.net",
        :password => "alfabeta",
        :server => "localhost",
        :port => 5432,
        :database => "wikistatistics.net",
        :schema => "public"
    }
    
    # Create it!
    connection = FluentQuery::Connection::new(driver, settings)

Now we have connection prepared for use.

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

    connection.select("[id], [name]") \
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

    connection.select(:id, :name) \
      .from(:maintainers) \
      .where(:id => 5, :company => "Wikia") \
      .where("[language] IN %%l", ["cz", "en"])   # %l will join items by commas
      .or \
      .where(:active => true)
      
Will give you expected result too and as you can see, it's much more 
readable, flexible, thus it's preferred. 

### Checking Out the Results

Query results can be executed by `#execute` which returns result object
or by `#do` which returns count of affected rows. Following methods for
checking out the results are available:

* `#each` which iterates through all returned rows,
* `#one` which returns first row only,
* `#single` which returns first value fo first row,
* `#assoc` which allows building complex Hashes (see below).
    
#### Associative Fetching

Special associative method is the `assoc` one which is directly inspired
by appropriate feature of the [Dibi][1] layer. It's aim is automatic
aggregation of returned rows to multidimensional Hashes.

Simply give it key names from your dataset. Be warn, only one or two 
levels (e.g. dimesions in resultant Hash) are supported:

    records = connection.select(:maintainer_id, :language) \
        .from(:sites) \
        .execute.assoc(:maintainer_id, :language)
    
Will transform the dataset:

    # maintainer_id, language, name
    [1, "en", "English Wikipedia"],
    [1, "es", "Spain Wikipedia"],
    [2, "cs", "Czech Wikihow"],
    [2, "ja", "Japan Wikihow"],

To the following structure:

        1 => {
            "en" => "English Wikipedia",
            "es" => "Spain Wikipedia"
        },
        
        2 => {
            "cs" => "Czech Wikihow",
            "ja" => "Japan Wikihow"
        }

### Inserts, Updates and Deletes

Inserting, updating and deleteing the records works by the same way as
selecting. Some examples:

    connection.insert(:maintainers, :name => "Wikimedia", :country => "United States")
    
    # Will be:
    #   INSERT INTO `maintainers` (`name`, `country`) VALUES ("Wikimedia", "United States")
    
    connection.update(:maintainers).set(:country => "Czech Republic").where(:id => 10).limit(1)
    
    # Will be:
    #   UPDATE `maintainers` SET `country` = "Czech Republic" WHERE `id` = 10 LIMIT 1
    
    connection.delete(:maintainers).where(:id => 10).limit(1)
    
    # Will be:
    #   DELETE FROM `maintainers` WHERE `id` = 10 LIMIT 1
    

#### Transactions

Transactions support is available manual:
    
* `connection.begin`,
* `connection.commit`,
* `connection.rollback`.

Or by automatic way:

    connection.transaction do
        #...
    end

### Compiled and Prepared Queries

Queries can be pre-prepared and pre-optimized by two different methods:

* `#compile` which compiles query to form of array of direct callbacks, 
so builds it and quotes all identifiers, keeps intact placeholders only,
* `#prepare` which transforms compiled query to prepared form as it's
known from DBD or PDO if it's supported by driver.

Simply call one of these methods upon the query and use resultant query
as usuall (of sure, without methods which would change it because it's
compiled so cannot be further changed).

Also note, SQL token calls cannot be called by mandatory way (e.g. you 
can call `#order` before `#where` etc.), but they will be reordered
in resultant both compiled and prepared query, so arguments given to 
execute must be taken to call in correct order according to resultant
SQL query. So in case of using compiled or prepared statements, it's 
good idea to write calls in the same order as SQL requires.

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
