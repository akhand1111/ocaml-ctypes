(*
 * Copyright (c) 2013 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

open OUnit
open Ctypes


let testlib = Dl.(dlopen ~filename:"clib/test_functions.so" ~flags:[RTLD_NOW])

module G = Generated_stubs
module Writer_context =
struct
  let prefix = "stubtest"
  let write _ = assert false
end

module Linker = Cstubs.Structs.Link(Writer_context)
module A = Struct_defs.Actual_definition
module M = Struct_defs.Man_page(Linker)

(* 
   Test that the layout retrieved from C for a partial struct definition is
   the same as the computed layout for the full definition.
*)
let test_struct_stub_layout () =
  assert_equal (sizeof A.padded) (sizeof M.padded);
  assert_equal (alignment A.padded) (alignment M.padded);
  assert_equal (offsetof A.i) (offsetof M.i);
  assert_equal (offsetof A.j) (offsetof M.j)


(* 
   Test passing an instance of a struct with a layout retrieved from C to a
   C function.
*)
let test_passing_generated_struct_instance () =
  let add = Foreign.foreign "add_padded_struct_fields" ~from:testlib
    (ptr A.padded @-> returning int) in

  let padded = make A.padded in
  begin
    setf padded A.i 15;
    setf padded A.j 25;
    let sum = add (addr padded) in
    assert_equal 40 sum
  end


let suite = "Struct stub tests" >:::
  ["struct stub layout"
    >:: test_struct_stub_layout;

   "passing instance of generated struct"
   >:: test_passing_generated_struct_instance;
  ]


let _ =
  run_test_tt_main suite
