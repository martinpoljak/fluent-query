FIFO Cache
==========

**FIFO Cache** is fast hash-like fixed size cache class with FIFO 
functionality which removes oldest or less accessed records based on 
[implicit heap][1].

### Examples and Tracking & Handicap Factor

Cache allows track both hits and puts and remove items from cache 
according these statistics. They are turned off by default, but can be 
turned on by setting `#factor` (or `:factor` in costructor) to another 
value than `0`.

*Handicap factor* is multiplier of the minimal hits count of all items 
in the cache. It's important set it in some cases.

If tracking is turned on and no handicap factor is explicitly set, 
handicap 1 is assigned to new items. It's safe, but not very acceptable 
because cache will become static after filling. So it's necessary (or at 
least higly reasonable) to set priority weighting factor to number 
higher than 1 according dynamics of your application.

Usage is simple (examples here are for demonstration purposes written
without factor set):
    
    require "fifocache"
    
    cache = Fifocache::new(3, :puts => true)   # or 300000, od sure :-)
    cache[:alfa] = 'alfa'
    cache[:beta] = 'beta'
    cache[:gama] = 'gama'
    cache[:delta] = 'delta'     # in this moment, :alfa is removed
    
But multiple addings are tracked, so subsequent call:

    cache[:beta] = 'beta'      # :beta, :gama, :delta in cache
    cache[:alfa] = 'alfa'      # :beta, :delta, :alfa in cache
    
…will cause `:gama` will be removed, not `:beta` because `:beta` is 
fresher now. If hits tracking is turned on:

    cache.hits = true           # you can do it in costructor too
    
    puts cache[:delta]          # cache hit
    cache[:gama] = 'gama'       # :beta, :delta, :gama in cache
    
…because `:beta` has been put-in two times, `:delta` has been hit 
recently, so `:alfa` is less accessed row and has been removed. In case 
of hits tracking turned off, `:delta` would be removed of sure and 
`:alfa` kept.
    
Changing size of existing cache is possible although reducing the size
is generally rather slow because of necessity to remove all redundant 
"oldest" rows.
    

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

Copyright &copy; 2010-2011 [Martin Kozák][3]. See `LICENSE.txt` for
further details.

[1]: http://www.cs.princeton.edu/courses/archive/spr09/cos423/Lectures/i-heaps.pdf
[2]: http://github.com/martinkozak/fifo-cache/issues
[3]: http://www.martinkozak.net/
