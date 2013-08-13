(*
 * Copyright (c) 2013 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

open Ctypes

module type StructDefs = functor (S : Structs.S) -> sig end

let prelude = "
#include <stdio.h>
#include <stddef.h>
int main(void) {"
and epilogue = "
  return 0;
}
"


(* Generic stub generator generation code *)
let generate ~prefix ~write ~headers (module Defs : StructDefs) =
  let module W = struct let prefix = prefix and write = write end in
  begin
    write prelude;
    ListLabels.iter headers
      ~f:(fun h -> write (Printf.sprintf "#include \"%s\"" h));
    let module M = Defs(Cstubs.Structs.Generate(W)) in ();
    write epilogue
  end

(* Call the stub generator generator with appropriate parameters *)
let () =
  generate
    ~prefix:"stubtest"
    ~write:print_endline
    ~headers:["tests/clib/test_functions.h"]
    (module Struct_defs.Man_page)
