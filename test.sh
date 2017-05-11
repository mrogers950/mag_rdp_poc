#!/bin/bash -xe
cmd=./parser

  # Single match and wildcard.
  $cmd 'a=1' 'a=1'
  $cmd '(a=1)' 'a=1'
  $cmd 'a=*' 'a=1'
  $cmd 'a=*' 'a=2'
! $cmd 'a=1' 'a=2'
! $cmd 'a=1' 'b=1'
! $cmd 'a=*' 'b=1'

  # Single OR.
  $cmd 'a=1 or b=1' 'a=1'
  $cmd 'a=1 or b=1' 'b=1'
  $cmd '(a=1 or b=1)' 'a=1'
  $cmd '(a=1) or (b=1)' 'b=1'
! $cmd 'a=1 or b=1' 'c=1'
! $cmd 'a=1 or b=1' 'b=2'

  # Multiple OR.
  $cmd 'a=1 or b=1 or b=2' 'a=1'
  $cmd 'a=1 or b=1 or b=2' 'b=1'
  $cmd 'a=1 or b=1 or b=2' 'b=2'
! $cmd 'a=1 or b=1 or b=2' 'a=2 b=3'

  # Single AND and wildcard.
  $cmd 'a=1 and b=1' 'a=1 b=1'
  $cmd 'a=1 and b=*' 'a=1 b=1'
  $cmd 'a=1 and b=*' 'a=1 b=2'
! $cmd 'a=1 and b=1' 'a=1'
! $cmd 'a=1 and b=1' 'b=1'

  # Multiple AND with some arbitrary nesting.
  $cmd 'a=1 and b=1 and c=1' 'a=1 b=1 c=1'
  $cmd '(a=1 and (b=1 and c=1))' 'a=1 b=1 c=1'
! $cmd 'a=1 and b=1 and c=1' 'b=1 c=1'

  # Combinations.
  $cmd 'a=1 and b=1 or b=2' 'a=1 b=1'
  $cmd 'a=1 and b=1 or b=2' 'a=1 b=2'
  $cmd '(a=1 and b=1) or b=2' 'b=2'
  $cmd '(a=1 and b=1) or b=2' 'a=1 b=1'
! $cmd 'a=1 and b=1 or b=2' 'b=2'
! $cmd 'a=1 and b=1 or b=2' 'a=1 b=3'
! $cmd '(a=1 and b=1) or b=2' 'b=1'
! $cmd '(a=1 and b=1) or b=2' 'a=2 b=1'

  $cmd 'a=1 or b=1 and c=1' 'a=1'
  $cmd 'a=1 or (b=1 and c=1)' 'a=1'
  $cmd 'a=1 or b=1 and c=1' 'b=1 c=1'
  $cmd 'a=1 or (b=1 and c=1)' 'b=1 c=1'
! $cmd 'a=1 or b=1 and c=1' 'a=2 b=1 c=2'
! $cmd 'a=1 or b=1 and c=1' 'b=1 c=2'

  $cmd '(a=1 or b=1) and c=1' 'a=1 c=1'
  $cmd '(a=1 or b=1) and c=1' 'b=1 c=1'
! $cmd '(a=1 or b=1) and c=1' 'a=1'
! $cmd '(a=1 or b=1) and c=1' 'b=1'
! $cmd '(a=1 or b=1) and c=1' 'c=1'

  $cmd '((a=1 or a=2) and (b=1 or (b=2 and c=1)))' 'a=1 b=1'
  $cmd '((a=1 or a=2) and (b=1 or (b=2 and c=1)))' 'a=2 b=1'
  $cmd '((a=1 or a=2) and (b=1 or (b=2 and c=1)))' 'a=1 b=2 c=1'
  $cmd '((a=1 or a=2) and (b=1 or (b=2 and c=1)))' 'a=2 b=2 c=1'
! $cmd '((a=1 or a=2) and (b=1 or (b=2 and c=1)))' 'a=2 b=3 c=1'
! $cmd '((a=1 or a=2) and (b=1 or (b=2 and c=1)))' 'a=2 b=2 c=2'

 # Parse errors.
! $cmd '(a=)' 'a=1'
! $cmd '(a=1 b=1)' 'a=1'
! $cmd '((a=1 or b=1)' 'a=1'
! $cmd 'a=1 or' 'a=1'
! $cmd 'a or b' 'a=1'
! $cmd '((a=1)or b=1)' 'a=1'
