(* Handlings of local labels and backpatching *)
(* Taken from the Moscow ML compiler *)

functor ResolveLocalLabels(structure BC : BUFF_CODE
			   structure IntFinMap : MONO_FINMAP where type dom = int
			   structure Labels : ADDRESS_LABELS
			   structure Crash : CRASH) : RESOLVE_LOCAL_LABELS =
  struct
    fun die s  = Crash.impossible ("ResolveLocalLabels." ^ s)

    type label = Labels.label
    datatype label_definition =
      Label_defined of int
    | Label_undefined of (int * int) list

    val label_table : label_definition IntFinMap.map ref = ref IntFinMap.empty

    fun reset_label_table () = label_table := IntFinMap.empty

    fun define_label lbl =
      let
	val lbl_k = Labels.key lbl
	fun define_label_in_map L =
	  let 
	    val curr_pos = !BC.out_position 
	  in
	    IntFinMap.add (lbl_k, Label_defined curr_pos, !label_table);
	    case L of
	      [] => ()
	    |  _ => (* Backpatching the list L of pending labels: *)
		(List.app (fn (pos,orig) => 
			   (BC.out_position := pos;
			    BC.out_long_i (curr_pos - orig)))
		 L;
		 BC.out_position := curr_pos)
	  end
      in
	case IntFinMap.lookup (!label_table) lbl_k
	  of NONE => define_label_in_map []
	| SOME (Label_defined _) => die ("define_label : label " ^ (Labels.pr_label lbl) ^ " already defined.")
	| SOME (Label_undefined L) => define_label_in_map L
      end

    fun out_label_with_orig orig lbl =
      let
	val lbl_k = Labels.key lbl
	fun out_label L =
	  (IntFinMap.add (lbl_k, Label_undefined ((!BC.out_position, orig) :: L), !label_table);
	   BC.out_long_i 0)
      in
	case IntFinMap.lookup (!label_table) lbl_k 
	  of NONE => out_label []
	  | SOME (Label_defined def) => BC.out_long_i (def - orig)
	  | SOME (Label_undefined L) => out_label L
      end

    fun out_label l = out_label_with_orig (!BC.out_position) l

  end
