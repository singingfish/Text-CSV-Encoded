# NAME

Text::CSV::Encoded - Encoding aware Text::CSV.

# SYNOPSIS

    # Here in Perl 5.8 or later
    $csv = Text::CSV::Encoded->new ({
        encoding_in  => "iso-8859-1", # the encoding comes into   Perl
        encoding_out => "cp1252",     # the encoding comes out of Perl
    });

    # parsing CSV is regarded as input
    $csv->parse( $line );      # $line is a iso-8859-1 encoded string
    @columns = $csv->fields(); # they are unicode data

    # combining list is regarded as output
    $csv->combine(@columns);   # they are unicode data
    $line = $csv->string();    # $line is a cp1252 encoded string

    # if you want for returned @columns to be encoded in $encoding
    #   or want for combining @columns to be assumed in $encoding
    $csv->encoding( $encoding );

    # change input/output encodings
    $csv->encoding_in('shiftjis')->encoding_out('utf8');
    $csv->eol("\n");

    open (my $in,  "sjis.csv");
    open (my $out, "output.csv");

    # change an encoding from shiftjis to utf8

    while( my $columns = $csv->getline( $in ) ) {
        $csv->print( $out, $columns );
    }

    close($in);
    close($out);

    # simple shortcuts
    # (regardless of encoding_in/out and encoding)

    $uni_columns = $csv->decode( 'euc-jp', $line );         # euc-jp => unicode
    $line        = $csv->encode( 'euc-jp', $uni_columns );  # unicode => euc-jp

    # pass check value to coder class
    $csv->coder->encode_check_value( Encode::FB_PERLQQ );

# DESCRIPTION

This module inherits [Text::CSV](https://metacpan.org/pod/Text::CSV) and is aware of input/output encodings.

# ENCODINGS

Acceptable names of encodings (`encoding_in`, `encoding_out` and `encoding`)
are depend upon its coder class (see to ["CODER CLASS"](#coder-class)). But these names should
be based on [Encode](https://metacpan.org/pod/Encode) supported names. See to [Encode::Supported](https://metacpan.org/pod/Encode::Supported) and [Encode::Alias](https://metacpan.org/pod/Encode::Alias).

# METHODS

## new

    $csv = Text::CSV::Encoded->new();

    Text::CSV::Encoded->error_diag unless $csv; # report error message

Creates a new Text::CSV::Encoded object. It can take all options of [Text::CSV](https://metacpan.org/pod/Text::CSV).
Of course, `binary` option is always on.

If Text::CSV::Encoded fails in constructing, you can get an error message using `error_diag`.
See to ["error\_diag" in Text::CSV](https://metacpan.org/pod/Text::CSV#error_diag).

The following options are supported by this method:

- encoding

    The encoding of list data in below cases.

        * list data returned by fields() after successful parse().
        * list data consumed by combine().
        * list reference returned by getline().
        * list reference taken by print().

    See to ["encoding"](#encoding).

- encoding\_in
- encoding\_io\_in
- encoding\_to\_parse

    The encoding for pre-parsing CSV strings. See to ["encoding\_in"](#encoding_in).

    `encoding_io_in` is an alias to `encoding_in`. If both `encoding_in`
    and `encoding_io_in` are set at the same time, the `encoding_in`
    takes precedence.

    `encoding_to_parse` is an alias to `encoding_in`. If both `encoding_in`
    and `encoding_to_parse` are set at the same time, the `encoding_in`
    takes precedence.

- encoding\_out
- encoding\_io\_out
- encoding\_to\_combine

    The encoding for combined CSV strings. See to ["encoding\_out"](#encoding_out).

    `encoding_io_out` is an alias to `encoding_out`. If both `encoding_out`
    and `encoding_io_out` are set at the same time, the `encoding_out`
    takes precedence.

    `encoding_to_combine` is an alias to `encoding_out`. If both `encoding_out`
    and `encoding_io_out` are set at the same time, the `encoding_out`
    takes precedence.

- coder\_class

    A name of coder class that really decodes and encodes data.

## encoding\_in

    $csv = $csv->encoding_in( $encoding );

The accessor to an encoding for pre-parsing CSV strings.
If no encoding is given, returns current `$encoding`, otherwise the object itself.

    $encoding = $csv->encoding_in()

In `parse` or `getline`, the `$csv` will assume CSV data as the given
encoding. If `encoding_in` is not specified or is set with false value ([undef](https://metacpan.org/pod/undef)),
it will assume input CSV strings as Unicode (not UTF-8) when [Text::CSV::Encoded::Coder::Encode](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Encode) is used.

    $csv->encoding_in( undef );
    # assume as Unicode when Text::CSV::Encoded::Coder::Encode is used.

If you pass a list reference that contains multiple encodings to the method,
the working are depend upon the coder class.
For example, if you use the coder class with [Text::CSV::Encoded::Coder::EncodeGuess](https://metacpan.org/pod/Text::CSV::Encoded::Coder::EncodeGuess),
it might guess the encoding from the given list.

    $csv->coder_class( 'Text::CSV::Encoded::Coder::EncodeGuess' );
    $csv->encoding_in( ['shiftjis', 'euc-jp', 'iso-20022-jp'] );

See to ["Coder Class"](#coder-class) and [Text::CSV::Encoded::Coder::EncodeGuess](https://metacpan.org/pod/Text::CSV::Encoded::Coder::EncodeGuess).

## encoding\_out

    $csv = $csv->encoding_out( $encoding );

The accessor to an encoding for converting combined CSV strings.
If no encoding is given, returns current `$encoding`, otherwise the object itself.

    $encoding = $csv->encoding_out();

In `combine` or `print`, the `$csv` will return a result string encoded in the
given encoding. If `encoding_out` is not specified or is set with false value,
it will return a result string as Unicode (not UTF-8).

    $csv->encoding_out( undef );
    # return as Unicode when Text::CSV::Encoded::Coder::Encode is used.

You must not pass a list reference to `encoding_out`, unlike `encoding_in` or `encoding`.

## encoding

    $csv = $csv->encoding( $encoding );
    $encoding = $csv->encoding();

The accessor to an encoding for list data in the below cases.

    * list data returned by fields() after successful parse().
    * list data consumed by combine().
    * list reference returned by getline().
    * list reference taken by print().

In other word, in `parse` and `getline`, `encoding` is an encoding of the returned list.
And in `combine` and `print`, it is assumed as an encoding for the passing list data.

If `encoding` is not specified or is set with false value (`undef`),
the field data will be regarded as Unicode (when [Text::CSV::Encoded::Coder::Encode](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Encode) is used).

    # ex.) a souce code is encoded in euc-jp, and print to stdout in shiftjis.
    @fields = ( .... );
    $csv->encoding('euc-jp')
        ->encoding_to_combine('shiftjis') # same as encoding_out
        ->combine( @fields ); # from euc-jp to shift_jis

    print $csv->string;

    $csv->encoding('shiftjis')
        ->encoding_to_parse('shiftjis') # same as encoding_in
        ->parse( $csv->string ); # from shift_jis to shift_jis

    print join(", ", $csv->fields );

If you pass a list reference contains multiple encodings to the method,
The working are depend upon the coder class. For example,
[Text::CSV::Encoded::EncodeGuess](https://metacpan.org/pod/Text::CSV::Encoded::EncodeGuess) might guess the encoding from the given list.

    $csv->coder_class( 'Text::CSV::Encoded::Coder::EncodeGuess' );
    $csv->encoding( ['ascii', 'ucs2'] )->combine( @cols );

See to ["Coder Class"](#coder-class) and [Text::CSV::Encoded::Coder::EncodeGuess](https://metacpan.org/pod/Text::CSV::Encoded::Coder::EncodeGuess).

## parse/combine/getline/print

    $csv->parse( $encoded_string );
    @unicode_array = $csv->fields();

    $csv->combine( @unicode_array );
    $encoded_string = $csv->string;

    $unicode_arrayref = $csv->getline( $io );
    # get arrayref contains unicode strings
    $csv->print( $io, $unicode_arrayref );
    # print $io with string encoded in $csv->encoded_in.

    $encoded_arrayref = $csv->getline( $io => $encoding )
    # directly encoded in $encoding.

Here is the relation of `encoding_in`, `encoding_out` and `encoding`.

    # CSV string        =>  (getline/parsed)  =>     Perl array
    #           assumed as                  encoded in
    #                encoding_in                encoding


    # Perl array        =>  (print/combined)  =>     CSV string
    #           assumed as                  encoded in
    #               encoding                    encoding_out

If you want to treat Perl array data as Unicode in Perl5.8 and later,
don't specify `encoding` (or set `undef` into `encoding`).

## decode

    $arrayref = $csv->decode( $encoding, $encoded_string );

    $arrayref = $csv->decode( $string );

A short cut method to convert CSV to Perl.
Without `$encoding`, `$string` is assumed as a Unicode.

The returned value status is depend upon its coder class.
With [Text::CSV::Encoded::Coder::Encode](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Encode), `$arrayref` contains Unicode strings.

## encode

    $encoded_string = $csv->encode( $encoding, $arrayref );

    $string = $csv->encode( $arrayref );

A short cut method to convert Perl to CSV.
With [Text::CSV::Encoded::Coder::Encode](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Encode), `$arrayref` is assumed to contain Unicode strings.

Without `$encoding`, return as is.

## coder\_class

    $csv = $csv->coder_class( $classname );
    $classname = $csv->coder_class();

Returns the coder class name. See to ["CODER CLASS"](#coder-class).

## coder

    $coder = $csv->coder();

Returns a coder object.

## automtic\_UTF8

In [Text::CSV\_XS](https://metacpan.org/pod/Text::CSV_XS) version 0.99 and [Text::CSV\_PP](https://metacpan.org/pod/Text::CSV_PP) version 1.30 or later,
They return UNICODE stinrgs in case of parsing utf8 encoded text.
Backend module has that feature, automatic\_UTF8 returns true.
(This method is for internal code.)

# CODER CLASS

Text::CSV::Encoded delegates the encoding converting process to another module.
Since version 5.8, Perl standardly has [Encode](https://metacpan.org/pod/Encode) module. So the default coder
module [Text::CSV::Encoded::Coder::Encode](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Encode) also uses it. In this case,
you don't have to take care of it.

In older Perl, the default is [Text::CSV::Encoded::Coder::Base](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Base). It does nothing.
So you have to make a coder module using your favorite converting module, for example,
[Unicode::String](https://metacpan.org/pod/Unicode::String) or [Jcode](https://metacpan.org/pod/Jcode) and so on.

Please check [Text::CSV::Encoded::Coder::Base](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Base) and [Text::CSV::Encoded::Coder::Encode](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Encode)
to make such a module.

In calling [Text::CSV::Encoded](https://metacpan.org/pod/Text::CSV::Encoded), you can set another coder module with `coder_class`;

    use Text::CSV::Encoded coder_class => 'YourCoder';

This will call `YourCoder` module in runtime.

## Use Encode module

Perl 5.8 or later, [Text::CSV::Encoded](https://metacpan.org/pod/Text::CSV::Encoded) use [Text::CSV::Encoded::Coder::Encode](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Encode)
as its backend engine. You can set `encoding_in`, `encoding_out` and `encoding`
with [Encode](https://metacpan.org/pod/Encode) supported encodings. See to [Encode::Supported](https://metacpan.org/pod/Encode::Supported) and [Encode::Alias](https://metacpan.org/pod/Encode::Alias).

Without `encoding` (or set `undef`), `parse`/`getline`/`getline_hr` return
list data whose entries are `Unicode` strings.
On the contrary, `combine`/`print` take data as `Unicode` string list.

About the extra methods `decode` and `encode`. `decode` returns `Unicode` string list
and `encode` takes `Unicode` string list. But If no `$encoding` is passed to `encode`,
it returns a non-Unicode CSV string for non-Unicode list data.

## Use Encode::Guess module

If you don't know definitely input CSV data encoding (for parse/getline),
[Text::CSV::Encoded::Coder::EncodeGuess](https://metacpan.org/pod/Text::CSV::Encoded::Coder::EncodeGuess) may be useful to you.
It inherits from [Text::CSV::Encoded::Coder::Encode](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Encode), so you can treate methods and
attributes as same as [Text::CSV::Encoded::Coder::Encode](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Encode). And it provides a guessing
fucntion with [Encode::Guess](https://metacpan.org/pod/Encode::Guess).

When it is backend coder class, `encoding_in` and `encoding` can take a encoding list reference,
and then it might guess the encoding from the given list.

    $csv->encoding_in( ['shiftjis', 'euc-jp'] )->parse( $sjis_or_eucjp_encoded_csv_string );

It is important to remember the guessing feature is not always successful.

Or, the method can be applied to `encoding`.
For exmaple, you want to convert data from Microsoft Excel to CSV.

    use Text::CSV::Encoded  coder_class => 'Text::CSV::Encoded::Coder::EncodeGuess';
    use Spreadsheet::ParseExcel;

    my $csv = Text::CSV::Encoded->new( eol => "\n" );
    $csv->encoding( ['ucs2', 'ascii'] ); # guessing ucs2 or ascii?
    $csv->encoding_out('shiftjis'); # print in shift_jis

    my $excel = Spreadsheet::ParseExcel::Workbook->Parse( $file );
    my $sheet = $excel->{Worksheet}->[0];

    for my $row ( $sheet->{MinRow} .. $sheet->{MaxRow} ) {
        my @fields;
        for my $col ( $sheet->{MinCol} ..  $sheet->{MaxCol} ) {
            my $cell = $sheet->{Cells}[$row][$col];
            push @fields, $cell->{Val};
        }
        $csv->print( \@fields );
    }

In this case, guessing for list data.
After combining, you may have a need to clear `encoding`.
Again remember that the feature is not always successful.

In addtion, Microsoft Excel data converting is a carefult thing.
See to ["CAVEATS" in Text::CSV\_XS](https://metacpan.org/pod/Text::CSV_XS#CAVEATS).

## Use XXX module

Someone might make a new coder module in older version Perl...
There is an example with [Jcode](https://metacpan.org/pod/Jcode) in [Text::CSV::Encoded::Coder::Base](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Base) document.

# TODO

- More sophisticated tests - Welcome!
- Speed

# SEE ALSO

[Text::CSV](https://metacpan.org/pod/Text::CSV), [Text::CSV\_XS](https://metacpan.org/pod/Text::CSV_XS), [Encode](https://metacpan.org/pod/Encode), [Encode::Guess](https://metacpan.org/pod/Encode::Guess), [utf8](https://metacpan.org/pod/utf8),
[Text::CSV::Encoded::Coder::Base](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Base),
[Text::CSV::Encoded::Coder::Encode](https://metacpan.org/pod/Text::CSV::Encoded::Coder::Encode),
[Text::CSV::Encoded::Coder::EncodeGuess](https://metacpan.org/pod/Text::CSV::Encoded::Coder::EncodeGuess)

# AUTHOR

Makamaka Hannyaharamitu, &lt;makamaka\[at\]cpan.org>

The basic idea for this module and suggestions were given by H.Merijn Brand.
He and Juerd advised me many points about documents and sources.

# COPYRIGHT AND LICENSE

Copyright 2008-2013 by Makamaka Hannyaharamitu

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
