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

(* [of_sorted_unique_array a] requires the array [a] to be sorted and to
   contain no duplicate elements. It converts this array, in linear time,
   to a set. *)

let of_sorted_unique_array a =
  of_sorted_unique_array_slice a 0 (Array.length a)

(* [of_array_destructive a] converts the array, in linear time, to a set.
   The array is modified (it is sorted). *)

let of_array_destructive a =
  (* Sort the array. *)
  Array.sort E.compare a;
  (* Remove duplicate elements. The unique elements remain in the
     slice of index 0 to index [n]. *)
  let equal x1 x2 = E.compare x1 x2 = 0 in
  let n = ArrayExtra.compress equal a in
  (* Convert this array slice to a tree. *)
  of_sorted_unique_array_slice a 0 n

(* [of_array] converts an array, in linear time, to a set. *)

let of_array a =
  a |> Array.copy |> of_array_destructive

(* [of_list] converts a list, in linear time, to a set. *)

let of_list xs =
  xs |> Array.of_list |> of_array_destructive

(* A naïve generic [of_list], whose complexity is O(n.log n). *)

let _of_list xs =
  List.fold_left (fun s x -> add x s) empty xs