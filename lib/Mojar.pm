package Mojar;
use Mojo::Base -strict;

our $VERSION = 0.015;

1
__END__

=head1 NAME

Mojar - Integration toolkit

=head1 SYNOPSIS

  use Mojar::Util q(detitlecase titlecase);
  use Mojar::Cache;

=head1 DESCRIPTION

A bag of tools for integrating to various APIs.  Most of the tools are provided
in separate distributions to continue the theme of keeping your footprint small.
All rely on having a fairly recent release of Mojolicious installed.

=head2 DISTRIBUTIONS

=over 4

=item Mojar::Mysql

Includes easy connection management, replication monitoring, and schema
analysis.

=item Mojar::Google::Analytics

Supports unattended logins and data extraction for reporting.

=item Mojar::Cron

Calculate when the next instance should run.

=item Mojar::BulkSms

Send (unattended) SMS via the net service.

=head1 SUPPORT

=head2 IRC

C<#mojo> on C<irc.perl.org>

=head2 WIKI

L<https://github.com/niczero/mojar/wiki>

=head1 DEVELOPMENT

=head2 Repository

L<http://github.com/niczero/mojar>

=head1 RATIONALE

Mojolicious is an awesome web application framework that just so happens to be
the foundation of a fabulous web integration platform.  The intention of Mojar
is to provide pluggable classes that extend the same philosophies while getting
you closer to connecting to third-party services.

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2012, Nic Sandfield.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
