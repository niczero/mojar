package Mojar;
use Mojo::Base -strict;

our $VERSION = 1.052;

1;
__END__

=head1 NAME

Mojar - Integration toolkit

=head1 SYNOPSIS

  use Mojar::Util q(snakecase unsnakecase);
  use Mojar::Cache;
  use Mojar::Log;

=head1 DESCRIPTION

A bag of tools for integrating to various APIs.  Most of the tools are provided
in separate distributions to continue the theme of keeping your footprint small.
All rely on having a fairly recent release of Mojolicious installed.

=head1 DISTRIBUTIONS

=over 4

=item Mojar::Mysql

Includes easy connection management, replication monitoring, and schema
analysis.

=item Mojar::Google::Analytics

Draw down your web analytics data for reporting.

=item Mojar::Cron

Calculate when the next instance should run.

=back

=head1 SUPPORT

=head2 IRC

C<nic> at C<#mojo> on C<irc.perl.org>

=head2 Wiki

L<https://github.com/niczero/mojar/wiki>

=head1 DEVELOPMENT

=head2 Repository

L<http://github.com/niczero/mojar>

=head1 RATIONALE

Mojolicious is an awesome web application framework that includes many great
building blocks even for non-web development and integration.  The intention of
Mojar is to provide pluggable classes that extend the same approach while
getting you closer to connecting to third-party services.

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2008--2012, Sebastian Riedel.
Copyright (C) 2012--2014, Nic Sandfield.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

All of this code is inspired by Mojolicious and the great work of Sebastian
Riedel.  In particular Config is a direct fork of its Mojolicious counterpart.

=cut
