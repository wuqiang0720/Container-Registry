use strict; use warnings;

package Text::Wrap;

use warnings::register;

BEGIN { require Exporter; *import = \&Exporter::import }

our @EXPORT = qw( wrap fill );
our @EXPORT_OK = qw( $columns $break $huge );

our $VERSION = '2024.001';
our $SUBVERSION = 'modern'; # back-compat vestige

BEGIN { eval sprintf 'sub REGEXPS_USE_BYTES () { %d }', scalar( pack('U*', 0x80) =~ /\xc2/ ) }

my $brkspc = "\x{a0}\x{202f}" =~ /\s/ ? '[^\x{a0}\x{202f}\S]' : '\s';

our $columns = 76;  # <= screen width
our $break = '(?>\n|\r\n|'.$brkspc.'\pM*)';
our $huge = 'wrap'; # alternatively: 'die' or 'overflow'
our $unexpand = 1;
our $tabstop = 8;
our $separator = "\n";
our $separator2 = undef;

sub _xlen { $_[0] =~ /^\pM/ + ( () = $_[0] =~ /\PM/g ) }

use Text::Tabs qw(expand unexpand);

sub wrap
{
	my ($ip, $xp, @t) = map +( defined $_ ? $_ : '' ), @_;

	local($Text::Tabs::tabstop) = $tabstop;
	my $r = "";
	my $tail = pop(@t);
	my $t = expand(join("", (map { /\s+\z/ ? ( $_ ) : ($_, ' ') } @t), $tail));
	my $lead = $ip;
	my $nll = $columns - _xlen(expand($xp)) - 1;
	if ($nll <= 0 && $xp ne '') {
		my $nc = _xlen(expand($xp)) + 2;
		warnings::warnif "Increasing \$Text::Wrap::columns from $columns to $nc to accommodate length of subsequent tab";
		$columns = $nc;
		$nll = 1;
	}
	my $ll = $columns - _xlen(expand($ip)) - 1;
	$ll = 0 if $ll < 0;
	my $nl = "";
	my $remainder = "";

	use re 'taint';

	pos($t) = 0;
	while ($t !~ /\G(?:$break)*\Z/gc) {
		if ($t =~ /\G((?>(?!\n)\PM\pM*|(?<![^\n])\pM+){0,$ll})($break|\n+|\z)/xmgc) {
			$r .= $unexpand 
				? unexpand($nl . $lead . $1)
				: $nl . $lead . $1;
			$remainder = $2;
		} elsif ($huge eq 'wrap' && $t =~ /\G((?>(?!\n)\PM\pM*|(?<![^\n])\pM+){$ll})/gc) {
			$r .= $unexpand 
				? unexpand($nl . $lead . $1)
				: $nl . $lead . $1;
			$remainder = defined($separator2) ? $separator2 : $separator;
		} elsif ($huge eq 'overflow' && $t =~ /\G([^\n]*?)(?!(?<![^\n])\pM)($break|\n+|\z)/xmgc) {
			$r .= $unexpand 
				? unexpand($nl . $lead . $1)
				: $nl . $lead . $1;
			$remainder = $2;
		} elsif ($huge eq 'die') {
			die "couldn't wrap '$t'";
		} elsif ($columns < 2) {
			warnings::warnif "Increasing \$Text::Wrap::columns from $columns to 2";
			$columns = 2;
			return @_;
		} else {
			die "This shouldn't happen";
		}
			
		$lead = $xp;
		$ll = $nll;
		$nl = defined($separator2)
			? ($remainder eq "\n"
				? "\n"
				: $separator2)
			: $separator;
	}
	$r .= $remainder;

	$r .= $lead . substr($t, pos($t), length($t) - pos($t))
		if pos($t) ne length($t);

	# the 5.6 regexp engine ignores the UTF8 flag, so using capture buffers acts as an implicit _utf8_off
	# that means on 5.6 we now have to manually set UTF8=on on the output if the input had it, for which
	# we extract just the UTF8 flag from the input and check if it forces chr(0x80) to become multibyte
	return REGEXPS_USE_BYTES && (substr($t,0,0)."\x80") =~ /\xc2/ ? pack('U0a*', $r) : $r;
}

sub fill 
{
	my ($ip, $xp, @raw) = map +( defined $_ ? $_ : '' ), @_;
	my @para;
	my $pp;

	for $pp (split(/\n\s+/, join("\n",@raw))) {
		$pp =~ s/\s+/ /g;
		my $x = wrap($ip, $xp, $pp);
		push(@para, $x);
	}

	# if paragraph_indent is the same as line_indent, 
	# separate paragraphs with blank lines

	my $ps = ($ip eq $xp) ? "\n\n" : "\n";
	return join ($ps, @para);
}

1;

__END__

