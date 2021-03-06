include List0 (** @inline *)

(** [stable_dedup] Same as [dedup] but maintains the order of the list and doesn't allow
    compare function to be specified (otherwise, the implementation in terms of Set.t
    would hide a heavyweight functor instantiation at each call). *)
let stable_dedup = Set.Poly.stable_dedup_list

(* This function is staged to indicate that real work (the functor application) takes
   place after a partial application. *)
let stable_dedup_staged (type a) ~(compare : a -> a -> int)
  : (a list -> a list) Base.Staged.t =
  let module Set =
    Set.Make (struct
      type t = a
      let compare = compare
      (* [stable_dedup_list] never calls these *)
      let t_of_sexp _ = assert false
      let sexp_of_t _ = assert false
    end)
  in
  Base.Staged.stage Set.stable_dedup_list
;;
