(*TypeInfo is part of the ElabInfo.  See ELAB_INFO for an
 overview of the different kinds of info.*)

(*$TYPE_INFO*)
signature TYPE_INFO =
  sig
    type lab
    type longid
    type Type
    type TyVar
    type TyEnv

    (*
     * Note that we record tyvars and types (and not typeschemes as 
     * one could imagine); this is not accidentally: we don't 
     * want to risk that the bound type variables are renamed (by alpha-conversion) ---
     * the compiler is a bit picky on the exact type information, so alpha-conversion
     * is not allowed on recorded type information!
     *)

    datatype TypeInfo =
	LAB_INFO of {index: int, tyvars: TyVar list, Type : Type }
			(* Attached to PATROW. Gives the alphabetic
			   index (0..n-1) for the record label. 
			   The Type field is the type of the pattern
			   corresponding to the label, tyvars are the bound 
                           type variables; there will only be bound tyvars
			   when attached to a pattern in a valbind. *)

      | RECORD_ATPAT_INFO of {Type : Type}
	                (* Attachec to RECORDatpat during elaboration,
			   The type (which is a record type) is used when 
			   overloading is resolved
			   to insert the correct indeces in LAB_INFO of patrows.
			 *)

      | VAR_INFO of {instances : Type list}
	                (* Attached to IDENTatexp,
			   instances is the list of types which have been 
			   chosen to instantiate the generic tyvars at this 
			   variable.
			 *)
      | VAR_PAT_INFO of {tyvars: TyVar list, Type: Type}
	                (* Attached to LAYEREDpat and LONGIDatpat (for LONGVARs)
			   The Type field is the type of the pattern corresponding
			   to the variable, tyvars are the bound type variables;
			   there will only be bound tyvars when attached to a pattern
			   in a valbind. *)
      | CON_INFO of {numCons: int, index: int, instances: Type list,
		     tyvars : TyVar list, Type: Type,longid:longid}
			(* Attached to IDENTatexp, LONGIDatpat, CONSpat.
			   numCons is the number of constructors for this type.
			   instances is the list of types wich have been
			   chosen to instantiate the generic tyars at this 
			   occurrence of the constructor.
			   Type is the type of the occurrence of the constructor,
			   tyvars are the bound type variables; 
			   there will only be bound tyvars when 
			   attached to a pattern in a valbind
			 *)
      | EXCON_INFO of {Type: Type,longid:longid}
			(* Attached to IDENTatexp, LONGIDatpat, CONSpat.
			   The Type field is the type of the occurrence of the
			   excon. *)
      | EXBIND_INFO of {TypeOpt: Type Option}
	                (* Attached to EXBIND
			 * None if nullary exception constructor *)
      | DATBIND_INFO of {TE: TyEnv}
	                (* ATTACHED to DATBIND
			 * The type environment associated with this datatype binding *)
      | EXP_INFO of {Type: Type} 
	                (* Attached to all exp's *)
      | MATCH_INFO of {Type: Type}
	                (* Attached to MATCH *)
      | PLAINvalbind_INFO of {tyvars: TyVar list, escaping: TyVar list, Type: Type}
	                (* Attached to PLAINvalbind 
			   for 'pat = exp' this is the type of the exp, and 
			   a list of bound type variables. *)

    type StringTree
    val layout : TypeInfo -> StringTree
  end;
