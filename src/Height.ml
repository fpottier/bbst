(* The following code taken from OCaml's Set library, and slightly adapted. *)

module[@inline] Make (E : sig type t end) = struct

  type key = E.t

  (* Trees are height-balanced. Each node stores its left child, key, right
     child, and height. The code maintains the invariant that the heights of
     the two children differ by at most 2. *)

  type tree =
    | TLeaf
    | TNode of { l : tree; v : key; r : tree; h : int }

  let[@inline] height t =
    match t with
    | TLeaf ->
        0
    | TNode { h; _ } ->
        h

  let[@inline] max (x : int) (y : int) =
    if x <= y then y else x

  let(* not inlined *) impossible () =
    assert false

  (* [create l v r] requires [l < v < r]. It constructs a node with left child
     [l], value [v], and right child [r]. The subtrees [l] and [r] must be
     balanced, and the difference in their heights must be at most 2. *)

  let[@inline] create l v r =
    let h = max (height l) (height r) + 1 in
    TNode { l; v; r; h }

  let[@inline] singleton x =
    (* This is equivalent to [create TLeaf x TLeaf]. *)
    TNode { l = TLeaf; v = x; r = TLeaf; h = 1 }

  (* [bal l v r] requires [l < v < r]. It constructs a node with left child
     [l], value [v], and right child [r]. The subtrees [l] and [r] must be
     balanced, and the difference in their heights must be at most 3. If
     necessary, one step of rebalancing is performed. *)

  let bal l v r =
    let hl = height l
    and hr = height r in
    if hl > hr + 2 then begin
      match l with
      | TLeaf -> impossible()
      | TNode { l = ll; v = lv; r = lr; _ } ->
      if height ll >= height lr then
        create ll lv (create lr v r)
      else
        match lr with
        | TLeaf -> impossible()
        | TNode { l = lrl; v = lrv; r = lrr; _ } ->
        create (create ll lv lrl) lrv (create lrr v r)
    end
    else if hr > hl + 2 then begin
      match r with
      | TLeaf -> impossible()
      | TNode { l = rl; v = rv; r = rr; _ } ->
      if height rr >= height rl then
        create (create l v rl) rv rr
      else
        match rl with
        | TLeaf -> impossible()
        | TNode { l = rll; v = rlv; r = rlr; _ } ->
        create (create l v rll) rlv (create rlr rv rr)
    end
    else
      (* This is equivalent to [create l v r]. *)
      let h = max hl hr + 1 in
      TNode { l; v; r; h }

  (* [add_min_element x t] requires [x < t]. *)

  let rec add_min_element x t =
    match t with
    | TLeaf ->
        singleton x
    | TNode { l; v; r; _ } ->
        bal (add_min_element x l) v r

  (* [add_max_element x t] requires [t < x]. *)

  let rec add_max_element x t =
    match t with
    | TLeaf ->
        singleton x
    | TNode { l; v; r; _ } ->
        bal l v (add_max_element x r)

  (* [join l v r] requires [l < v < r]. It makes no assumptions about
     the heights of the subtrees [l] and [r]. *)

  let rec join l v r =
    match l, r with
    | TLeaf, _ ->
        add_min_element v r
    | _, TLeaf ->
        add_max_element v l
    | TNode { l = ll; v = lv; r = lr; h = lh },
      TNode { l = rl; v = rv; r = rr; h = rh } ->
        if lh > rh + 2 then bal ll lv (join lr v r) else
        if rh > lh + 2 then bal (join l v rl) rv rr else
        create l v r

  type view =
    | Leaf
    | Node of tree * key * tree

  let[@inline] view t =
    match t with
    | TLeaf ->
        Leaf
    | TNode { l; v; r; _ } ->
        Node (l, v, r)

  let[@inline] make v =
    match v with
    | Leaf ->
        TLeaf
    | Node (l, v, r) ->
        join l v r

end