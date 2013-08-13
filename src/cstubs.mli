(*
 * Copyright (c) 2013 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

module type Writer_context =
sig
  val prefix : string
  val write : (string -> unit)
end

module Structs :
sig
  module Generate (W : Writer_context) : Structs.S
  module Link (W : Writer_context) : Structs.S
    with type ('a, 's) field = ('a, 's) Ctypes.field
  val record : string -> int -> unit
  val resolve : string -> int
end
