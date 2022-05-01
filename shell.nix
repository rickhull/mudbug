with import <nixpkgs> {};
ruby.withPackages (ps: with ps; [ rest-client rake ])
