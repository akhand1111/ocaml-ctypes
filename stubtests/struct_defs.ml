(*
 * Copyright (c) 2013 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

open Ctypes

(* The actual definition of 'padded' in the header *)
module Actual_definition =
struct
  type padded
  let padded : padded structure typ = structure "padded_struct"
  let padding      = field padded "padding" (array 1 char)
  let i            = field padded "i" int
  let more_padding = field padded "more_padding" (array 3 char)
  let j            = field padded "j" int
  let tail_padding = field padded "tail_padding" (array 33 char)
  let () = seal padded
end

module Man_page (S : Structs.S) =
struct
  open S

  (* The "man page" definition *)
  type padded
  let padded : padded structure typ = structure "padded_struct"
  let i = field padded "i" int
  let j = field padded "j" int
  let () = seal padded
end
