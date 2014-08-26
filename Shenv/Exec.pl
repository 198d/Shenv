use v5.016;
use warnings;

use IO::Socket::UNIX;

use Shenv::Client;


source(\%ENV);
exec @ARGV;
