maven-repo
==========

A temporary home for pants maven artifacts not hosted on maven central yet.

releasing
=========

Requires a bintray account with membership in the https://bintray.com/pantsbuild org.

+ Commit new jars, poms, etc and push to origin.
+ run `./sync-bintray.sh`

