package Dist::Zilla::Plugin::AddModule::RegexpCommon::FromRegexpPattern;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Moose;
with (
        'Dist::Zilla::Role::FileGatherer',
);

has regexp_pattern_module => (is => 'rw', required => 1);
has regexp_common_module => (is => 'rw', required => 1);
has category => (is => 'rw', required => 1);

use namespace::autoclean;

sub gather_files {
    require Dist::Zilla::File::InMemory;
    require Module::Path::More;

    my ($self, $arg) = @_;

    my $rp_mod = $self->regexp_pattern_module;
    $self->log_fatal("Please specify regexp_pattern_module") unless $rp_mod;
    $rp_mod = "Regexp::Pattern::$rp_mod" unless $rp_mod =~ /\ARegexp::Pattern::/;

    my $rc_mod = $self->regexp_common_module;
    $self->log_fatal("Please specify regexp_common_module") unless $rc_mod;
    $rc_mod = "Regexp::Common::$rc_mod" unless $rc_mod =~ /\ARegexp::Common::/;

    $self->log_fatal("Please specify category") unless $self->category;

    my @content;
    push @content, "package $rc_mod;\n";
    push @content, "\n";
    push @content, "# DATE\n";
    push @content, "# VERSION\n";
    push @content, "\n";
    push @content, "use strict;\n";
    push @content, "use warnings;\n";
    push @content, "\n";
    push @content, "use Regexp::Common 'pattern';\n";
    push @content, "\n";

    # TODO

    my $mod = $self->regexp_common_module;
    (my $mod_path = "lib/$mod.pm") =~ s!::!/!g;

    my $fileobj = Dist::Zilla::File::InMemory->new({
        name => $mod_path,
        mode => 0644,
        content => join("", @content),
    });
    $fileobj->name($self->dest);

    $self->log(["Adding module %s at %s ...",
                $self->regexp_common_module, $mod_path]);
    $self->add_file($fileobj);
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Generate a Regexp::Common module from a Regexp::Pattern module

=for Pod::Coverage .+

=head1 SYNOPSIS

In F<dist.ini>:

 [AddModule::RegexpCommon::FromRegexpPattern]
 name=Module::List
 dest=t/lib/Module/List.pm

To add more files:

 [AddModule::FromFS / AddModulePathMore]
 name=Module::Path::More
 dest=t/lib/Module/Path/More.pm


=head1 DESCRIPTION

This plugin adds a module source file from local filesystem to your build.


=head1 SEE ALSO

L<Dist::Zilla::Plugin::AddFile::FromFS>
