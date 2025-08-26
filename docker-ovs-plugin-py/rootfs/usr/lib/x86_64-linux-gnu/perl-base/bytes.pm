package bytes 1.09;

use v5.38;

BEGIN { $bytes::hint_bits = 0x0000_0008 }

sub   import { $^H |=  $bytes::hint_bits }
sub unimport { $^H &= ~$bytes::hint_bits }

sub chr    :prototype(_)     { BEGIN { import() } &CORE::chr    }
sub index  :prototype($$;$)  { BEGIN { import() } &CORE::index  }
sub length :prototype(_)     { BEGIN { import() } &CORE::length }
sub ord    :prototype(_)     { BEGIN { import() } &CORE::ord    }
sub rindex :prototype($$;$)  { BEGIN { import() } &CORE::rindex }
sub substr :prototype($$;$$) { BEGIN { import() } &CORE::substr }

__END__

