// Copyright (C) 2020 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/LICENSE file.

call_lambda should_call/bool func/Lambda:
  if should_call: return func.call
  return null

main:
  local ::= 499
  call_lambda true::
    local++
  unresolved
