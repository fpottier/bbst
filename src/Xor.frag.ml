(******************************************************************************)
(*                                                                            *)
(*                                   Bistro                                   *)
(*                                                                            *)
(*                       François Pottier, Inria Paris                        *)
(*                                                                            *)
(*       Copyright 2024--2024 Inria. All rights reserved. This file is        *)
(*       distributed under the terms of the GNU Library General Public        *)
(*       License, with an exception, as described in the file LICENSE.        *)
(*                                                                            *)
(******************************************************************************)

(* -------------------------------------------------------------------------- *)

(* Symmetric difference. *)

(* This is a simple, elegant version of [xor].

let rec xor (t1 : tree) (t2 : tree) : tree =
  match VIEW(t1), VIEW(t2) with
  | LEAF, _ ->
      t2
  | _, LEAF ->
      t1
  | NODE(_, _, _), NODE(l2, k2, r2) ->
      let l1, b, r1 = split k2 t1 in
      let l = xor l1 l2
      and r = xor r1 r2 in
      if b then join2 l r else join l k2 r

 *)

(* Except in the case where [t1] or [t2] is empty, [xor t1 t2] cannot be
   equal to [t1] or [t2]. So there is no need to attempt to preserve
   sharing when constructing new nodes. *)

let rec xor (t1 : tree) (t2 : tree) : tree =
  match VIEW(t1), VIEW(t2) with
  | LEAF, _ ->
      t2
  | _, LEAF ->
      t1
  | NODE(_, _, _), NODE(l2, k2, r2) ->
      if t1 == t2 then leaf else (* fast path *)
      if BOTH_EMPTY(l2, r2) then
        (* [t2] is [singleton k2]. *)
        if mem k2 t1 then
          remove k2 t1
        else
          add k2 t1
      else
        let l1, b, r1 = split k2 t1 in
        let l = xor l1 l2
        and r = xor r1 r2 in
        if b then
          join2 l r
        else
          join l k2 r
