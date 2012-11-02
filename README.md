# Mojar

A small booster pack for Mojolicious, written with similar principles to
Mojolicious itself.  A key requirement for all included code is a small
filesystem footprint, with minimal dependencies outside of perl core and
Mojolicious.

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
