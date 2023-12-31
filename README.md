## Trie Filter
Trie index word filter and censor.

monk 

<sup>Copyright (c) 2023, MIT License</sup>

## Details
It's pretty much the same as [FilterPlus](https://github.com/monk-afk/filterplus/tree/main) but without the Minetest global callbacks. Works in in terminal.

The blacklist is indexed by length->anchor(Z)->anchor(A)->word.

Removes URLs, trims extra spaces, and joins gapped words.

Censored words are replaced with asterisk(*).

##
Version **`0.009`**