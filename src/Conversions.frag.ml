(* -------------------------------------------------------------------------- *)

(* [elements] converts a set, in linear time, to a sorted list. *)

let rec elements (t : tree) (k : elt list) : elt list =
  match VIEW(t) with
  | LEAF ->
      k
  | NODE(l, v, r) ->
      elements l (v :: elements r k)

let[@inline] elements (t : tree) : elt list =
  elements t []

(* -------------------------------------------------------------------------- *)

(* [to_seq] converts a set to a sorted OCaml sequence (whose total
   cost is linear). *)

let to_seq (t : tree) : key Seq.t =
  fun () -> Enum.(to_seq_node (enum t))

(* -------------------------------------------------------------------------- *)

(* [to_array_slice t a i] writes the elements of the tree [t] to the
   array slice determined by the array [a] and the start index [i].
   It returns the end index of this slice. *)

let rec to_array_slice (t : tree) a i : int =
  if debug then assert (0 <= i && i + cardinal t <= Array.length a);
  match VIEW(t) with
  | LEAF ->
      i
  | NODE(l, v, r) ->
      let i = to_array_slice l a i in
      a.(i) <- v;
      let i = i + 1 in
      to_array_slice r a i

(* -------------------------------------------------------------------------- *)

(* [to_array] converts a set, in linear time, to a sorted array. *)

let to_array (t : tree) : key array =
  match VIEW(t) with
  | LEAF ->
      [||]
  | NODE(_, dummy, _) ->
      let n = cardinal t in
      let a = Array.make n dummy in
      let j = to_array_slice t a 0 in
      if debug then assert (n = j);
      a

(* -------------------------------------------------------------------------- *)

(* [of_sorted_unique_array_slice a i j] requires the array slice defined by
   array [a], start index [i], and end index [j] to be sorted and to contain
   no duplicate elements. It converts this array slice, in linear time, to a
   set. *)

let rec of_sorted_unique_array_slice a i j =
  if debug then assert (0 <= i && i <= j && j <= Array.length a);
  let n = j - i in
  match n with
  | 0 ->
      empty
  | 1 ->
      let x = a.(i) in
      singleton x
  | 2 ->
      let x = a.(i)
      and y = a.(i+1) in
      doubleton x y
  | 3 ->
      let x = a.(i)
      and y = a.(i+1)
      and z = a.(i+2) in
      tripleton x y z
  | _ ->
      let k = i + n/2 in
      let l = of_sorted_unique_array_slice a i k
      and v = a.(k)
      and r = of_sorted_unique_array_slice a (k+1) j in
      join_weight_balanced l v r

(* -------------------------------------------------------------------------- *)

(* [of_sorted_unique_array a] requires the array [a] to be sorted and to
   contain no duplicate elements. It converts this array, in linear time,
   to a set. *)

let[@inline] of_sorted_unique_array a =
  of_sorted_unique_array_slice a 0 (Array.length a)

(* -------------------------------------------------------------------------- *)

(* [of_array] converts an array to a set. This algorithm is adaptive. If the
   array is sorted, then its time complexity is O(n). If the array is not
   sorted, then its time complexity gradually degenerates to O(n.log n). *)

(* Each run of consecutive increasing elements is converted to a set, in
   linear time in the length of this run. Then, the union of these sets
   is computed. *)

let of_array a =
  let yield accu (i, j) = union accu (of_sorted_unique_array_slice a i j) in
  ArrayExtra.foreach_increasing_run E.compare yield empty a

(* -------------------------------------------------------------------------- *)

(* [of_list] converts a list to a set. *)

let of_list xs =
  xs |> Array.of_list |> of_array
