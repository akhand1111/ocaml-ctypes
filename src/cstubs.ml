(*
 * Copyright (c) 2013 Jeremy Yallop.
 *
 * This file is distributed under the terms of the MIT License.
 * See the file LICENSE for details.
 *)

open Static

module type Writer_context =
sig
  val prefix : string
  val write : (string -> unit)
end

let sprintf = Printf.sprintf

module Ids (C : Writer_context) =
struct
  let field_offset ~tag ~label =
    sprintf "%s_struct_offset_%s_%s" C.prefix tag label

  let struct_size ~tag =
    sprintf "%s_struct_size_%s" C.prefix tag

  let union_size ~tag =
    sprintf "%s_union_size_%s" C.prefix tag

  let struct_alignment ~tag =
    sprintf "%s_struct_alignment_%s" C.prefix tag

  let union_alignment ~tag =
    sprintf "%s_union_alignment_%s" C.prefix tag
end

module Structs =
struct
  let sizes = Hashtbl.create 16
  let resolve name = Hashtbl.find sizes name
  let record name size = Hashtbl.add sizes name size

  module Generate (C : Writer_context) =
  struct
    module Ids = Ids(C)

    let write_register_function name expression =
      C.write 
        (sprintf
           "printf(\"let () = Cstubs.Structs.record \\\"%s\\\" %%zu\\n\", %s);\n"
           name expression)

    let write_field_offset_function ~tag ~label = 
      write_register_function (Ids.field_offset ~tag ~label)
        (sprintf "offsetof (struct %s, %s)" tag label)

    let write_union_size_function ~tag = 
      write_register_function (Ids.union_size ~tag)
        (sprintf "sizeof (union %s)" tag)

    let write_struct_size_function ~tag = 
      write_register_function (Ids.struct_size ~tag)
        (sprintf "sizeof (struct %s)" tag)

    let write_struct_alignment_function ~tag = 
      write_register_function (Ids.struct_alignment ~tag)
        (sprintf "offsetof (struct { char c; struct %s s; }, s)" tag)

    let write_union_alignment_function ~tag = 
      write_register_function (Ids.union_alignment ~tag)
        (sprintf "offsetof (struct { char c; union %s s }, s)" tag)

    type (_, _) field = unit

    let field (type k) (s : (_, k) structured typ) label ty =
      match s with
      | Struct { tag; spec = Incomplete spec} ->
        write_field_offset_function ~tag ~label
      | _ -> ()

    let seal (type a) (type k) (s : (a, k) structured typ) : unit =
      match s with
      | Struct { tag } ->
        begin
          write_struct_size_function ~tag;
          write_struct_alignment_function ~tag;
        end
      | Union { utag = tag } -> 
        begin
          write_union_size_function ~tag;
          write_union_alignment_function ~tag;
        end
  end
  module Link (C : Writer_context) =
  struct
    module Ids = Ids(C)

    type ('a, 's) field = ('a, 's) Static.field

    let field (type k) (s : (_, k) structured typ) label ftype =
      match s with
      | Union u ->
        ensure_unsealed u;
        let field = { ftype; foffset = 0; fname = label } in
        u.ufields <- BoxedField field :: u.ufields;
        field
      | Struct ({ tag; spec = Incomplete spec } as s) ->
        let foffset = resolve (Ids.field_offset ~tag ~label) in
        let field = { ftype; foffset; fname = label } in
        s.fields <- BoxedField field :: s.fields;
        field
      | Struct { tag; spec = Complete _ } ->
        raise (ModifyingSealedType tag)

    (* TODO: the struct types generated here don't have a corresponding ffitype,
       so they can't be passed by value using libffi. *)
    let seal (type a) (type s) : (a, s) structured typ -> unit = function
      | Struct { fields = [] } ->
        raise (Unsupported "struct with no fields")
      | Struct { spec = Complete _; tag } ->
        raise (ModifyingSealedType tag)
      | Struct ({ spec = Incomplete _ } as s) ->
        s.fields <- List.rev s.fields;
        let alignment = resolve (Ids.struct_alignment s.tag) in
        let size = resolve (Ids.struct_size s.tag) in
        let raw = Static_stubs.make_unpassable_structspec ~size ~alignment in
        s.spec <- Complete { RawTypes.raw; size; alignment; passable = false;
                             name = "struct " ^ s.tag }
      | Union { ufields = [] } ->
        raise (Unsupported "union with no fields")
      | Union u when u.ucomplete ->
        raise (ModifyingSealedType u.utag)
      | Union u -> begin
        ensure_unsealed u;
        u.ufields <- List.rev u.ufields;
        u.usize <- resolve (Ids.union_size u.utag);
        u.ualignment <- resolve (Ids.union_alignment u.utag);
        u.ucomplete <- true
      end
  end
end
