# NAME

Text::CSV::Encoded - Encoding aware Text::CSV.

# VERSION

undef

# SYNOPSIS

    # Here in Perl 5.8 or later
    $csv = Text::CSV::Encoded->new ({
        encoding_in  => "iso-8859-1", # the encoding comes into   Perl
        encoding_out => "cp1252",     # the encoding comes out of Perl
    });

    # parsing CSV is regarded as input
    $csv->parse( $line );      # $line is a iso-8859-1 encoded string
    @columns = $csv->fields(); # they are unicode data

# DESCRIPTION

This module inherits [Text::CSV](https://metacpan.org/pod/Text::CSV) and is aware of input/output encodings.

# REQUIREMENTS

This distribution requires the following modules:

- [ExtUtils::MakeMaker](https://metacpan.org/pod/ExtUtils::MakeMaker)
- [IO::Handle](https://metacpan.org/pod/IO::Handle)
- [Test::Harness](https://metacpan.org/pod/Test::Harness)
- [Test::More](https://metacpan.org/pod/Test::More)
- [Test::Pod](https://metacpan.org/pod/Test::Pod) (version 1.41)
- [Text::CSV](https://metacpan.org/pod/Text::CSV) (version 1.31)
