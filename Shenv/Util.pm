package Shenv::Util;


use v5.016;
use warnings;

use Exporter qw(import);


sub parse_value_pair {
  my ($line)  = @_;
  chomp($line);
  split("=", $line, 2);
}


sub set_value_pair {
  my ($line, $hashref) = @_;
  my ($name, $value) = parse_value_pair($line);

  $$hashref{$name} = $value;

  return ($name, $value);
}


our @EXPORT = qw(parse_value_pair set_value_pair);
