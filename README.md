# Mojar

A small booster pack for Mojolicious.
The (soft) criteria are
*   Filesystem footprint kept small.
*   Number of package dependencies kept low.
*   XS files avoided where practical.
*   Non-linux platforms (incl Strawberry Perl) supported where practical.

## Features

*   Mojar::Cache

    A bare-bones cache.  Aims to be sufficient for everyday use while providing
an easy upgrade path to CHI when better performance or richer functionality is
required.

*   Mojar::Cache::Simple

    A specialisation of Mojar::Cache with an upper limit on the quantity of
keys stored; once the limit is exceeded, the oldest key is deleted.

*   Mojolicious::Plugin::Run

    A fork of MojoX::Run; provides asynchronous execution of external commands
and perl closures.  (This fork is compatible with Mojolicious v3.)

*   Mojolicious::Plugin::Run::Open3

    A fork of IPC::Run; provides portable execution of external commands and
perl closures.  (This fork has provision for perl closures.)

*   Mojar::Google::Analytics

    http://niczero.github.com/mojar-google-analytics/

    An extension to facilitate read access to a GA service account.  (Currently
only blocking connections are supported.)

## Status

Pre-alpha, please come back later or discuss on irc.
