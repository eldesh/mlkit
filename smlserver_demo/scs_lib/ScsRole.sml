signature SCS_ROLE =
  sig
    (* This structure is the ML API for the Oracle package scs_role,
       see scs-roles-create.sql *)

    (* [role] Pre-defined roles. This list is likely to change depending 
       on what kind of web-site you are building. *)
    datatype role = 
      SiteAdm
    | StudAdm
    | SysAdm
    | OaAdm
    | UcsPbSupervisorAdm  (* Created in ucs-pb-supervisor-lists-initialdata-create.sql *)
    | UcsPbProjectAdm     (* Created in ucs-pb-initialdata-create.sql *)
    | UcsEbEventEditor    (* Created in ucs-eb-initialdata-create.sql *)
    | ScsPersonAdm        (* Created in scs-users-initialdata-create.sql *)
    | UcsEduInfo          (* Created in ucs-edus-patch006.sql *)
    | PhdAdm              (* Created in ucs-edus-patch006.sql *)
    | PortraitAdm         (* Created in ucs-edus-patch006.sql *)
    | UcsPrPersonaleAdm   (* Created in ucs-pr-patch002.sql *)
    | UcsPrAdm		  (* Created in ucs-pr-patch002.sql *)
    | UcsPrITAdm	  (* Created in ucs-pr-patch002.sql *)
    | UcsPrInternAdm      (* Created in ucs-pr-patch002.sql *)
    | UcsTrTimeRecordAdm  (* Created in ucs-tr-initialdata-create.sql *)
    | UcsObOptagAdm  	  (* Created in ucs-ob-initialdata-create.sql *)
    | UcsCbCourseAdm  	  (* Created in ucs-cb-initialdata-create.sql *)
    | UcsCbITUAdm  	  (* Created in ucs-cb-initialdata-create.sql *)
    | UcsCbTITAdm  	  (* Created in ucs-cb-initialdata-create.sql *)
    | UcsCbEBUSSAdm  	  (* Created in ucs-cb-initialdata-create.sql *)
    | UcsCbRoomAdm	  (* Created in ucs-cb-initialdata-create.sql *)
    | UcsCbItSupportAdm   (* Created in ucs-cb-release2-create.sql *)
    | UcsCbLinjeAdm       (* Created in ucs-cb-release3-create.sql *)
    | UcsPrRucAdm	  (* Created in ucs-pr-patch005.sql.sql *)
    | UcsPrEbussAdm	  (* Created in ucs-pr-patch005.sql.sql *)
    | Other of string

    (* [fromString str] returns the corresponding role which is either
       one of the pre-defined roles in the role datatype or the role
       Other. The function is used to convert between the datatype
       role and the representation in the database. *)
    val fromString : string -> role
 
    (* [toString role] returns the string representation of the role
       as stored in the database. *)
    val toString : role -> string

    (* [has_p uid role] returns true if user uid has role role;
       otherwise returns false. *)
    val has_p     : int -> role -> bool

    (* [has_one_p uid roles] returns true if user uid has atleast one
       of the roles in the role list roles *)
    val has_one_p : int -> role list -> bool

    (* [has_one_or_empty_p uid roles] same as has_one_p except that it
       returns true if the role list roles is empty. *)
    val has_one_or_empty_p : int -> role list -> bool

    (* [flushRoleCache ()] flushes the cache used to store role
       relations. The cache limits the burden on the database by not
       doing the same role queries many times within a litle time
       period like 5 minutes. *)
    val flushRoleCache : unit -> unit

    (* [getAllRoles user_id] returns a list of roles for the user *)
    val getAllRoles : int -> role list
  end

structure ScsRole :> SCS_ROLE =
  struct
    datatype role = 
      SiteAdm
    | StudAdm
    | SysAdm
    | OaAdm
    | UcsPbSupervisorAdm
    | UcsPbProjectAdm
    | UcsEbEventEditor
    | ScsPersonAdm
    | UcsEduInfo
    | PhdAdm
    | PortraitAdm
    | UcsPrPersonaleAdm
    | UcsPrAdm		
    | UcsPrITAdm	
    | UcsPrInternAdm    
    | UcsTrTimeRecordAdm
    | UcsObOptagAdm  	  
    | UcsCbCourseAdm
    | UcsCbITUAdm  	
    | UcsCbTITAdm  	
    | UcsCbEBUSSAdm  	
    | UcsCbRoomAdm
    | UcsCbItSupportAdm
    | UcsCbLinjeAdm
    | UcsPrRucAdm	  
    | UcsPrEbussAdm	  
    | Other of string

    fun fromString str = 
      case str of
        "SiteAdm"            => SiteAdm
      | "SysAdm"	     => SysAdm
      | "StudAdm"	     => StudAdm
      | "UcsPbVejlederAdm"   => UcsPbSupervisorAdm
      | "UcsPbProjectAdm"    => UcsPbProjectAdm
      | "OaAdm"		     => OaAdm
      | "UcsEbEventEditor"   => UcsEbEventEditor
      | "ScsPersonAdm"	     => ScsPersonAdm
      | "UcsEduInfo"	     => UcsEduInfo
      | "PhdAdm"	     => PhdAdm
      | "PortraitAdm"	     => PortraitAdm
      | "UcsPrPersonaleAdm"  => UcsPrPersonaleAdm
      | "UcsPrAdm"	     => UcsPrAdm		
      | "UcsPrITAdm"	     => UcsPrITAdm	
      | "UcsPrInternAdm"     => UcsPrInternAdm    
      | "UcsTrTimeRecordAdm" => UcsTrTimeRecordAdm
      | "UcsObOptagAdm"      => UcsObOptagAdm 
      | "UcsCbCourseAdm"     => UcsCbCourseAdm
      | "UcsPrRucAdm"	     => UcsPrRucAdm  
      | "UcsPrEbussAdm"	     => UcsPrEbussAdm
      | "UcsCbITUAdm"  	     => UcsCbITUAdm     
      | "UcsCbTITAdm"  	     =>	UcsCbTITAdm     
      | "UcsCbEBUSSAdm"	     =>	UcsCbEBUSSAdm   
      | "UcsCbRoomAdm"	     => UcsCbRoomAdm
      | "UcsCbItSupportAdm"  => UcsCbItSupportAdm
      | "UcsCbLinjeAdm"      => UcsCbLinjeAdm
      | s => Other s
 
    (* [toString role] returns the string representation of the role
       as stored in the database. *)
    fun toString (role:role) =
      case role of
        SiteAdm            => "SiteAdm"
      | StudAdm		   => "StudAdm"
      | SysAdm		   => "SysAdm"
      | OaAdm		   => "OaAdm"
      | UcsPbSupervisorAdm => "UcsPbVejlederAdm"
      | UcsPbProjectAdm	   => "UcsPbProjectAdm"
      | UcsEbEventEditor   => "UcsEbEventEditor"
      | ScsPersonAdm	   => "ScsPersonAdm"
      | UcsEduInfo	   => "UcsEduInfo"
      | PhdAdm		   => "PhdAdm"
      | PortraitAdm	   => "PortraitAdm"
      | UcsPrPersonaleAdm  => "UcsPrPersonaleAdm"
      | UcsPrAdm	   => "UcsPrAdm"		
      | UcsPrITAdm	   => "UcsPrITAdm"	
      | UcsPrInternAdm     => "UcsPrInternAdm"    
      | UcsTrTimeRecordAdm => "UcsTrTimeRecordAdm"
      | UcsObOptagAdm	   => "UcsObOptagAdm"
      | UcsCbCourseAdm	   => "UcsCbCourseAdm"
      | UcsCbITUAdm  	   => "UcsCbITUAdm"     
      | UcsCbTITAdm  	   => "UcsCbTITAdm"     
      | UcsCbEBUSSAdm      => "UcsCbEBUSSAdm"   
      | UcsCbRoomAdm	   => "UcsCbRoomAdm"
      | UcsCbItSupportAdm  => "UcsCbItSupportAdm"
      | UcsCbLinjeAdm      => "UcsCbLinjeAdm"
      | UcsPrRucAdm	   => "UcsPrRucAdm"  
      | UcsPrEbussAdm	   => "UcsPrEbussAdm"
      | Other s => s
	  
    (* We cache the result for 5 minutes.
       Cache def: (uid,role) -> bool
       We flush the cache when we edit roles, (i.e., se script files
       in directory /web/ucs/www/scs/admin/role/ *)

    local
      val role_cache_def = 
	Ns.Cache.get(Ns.Cache.Pair Ns.Cache.Int Ns.Cache.String,
		     Ns.Cache.Bool,
		     "ScsRoleCache",
		     Ns.Cache.WhileUsed 300)
      fun has_p' (uid:int,role:string) =
	let
	  val role_sql = `
	    select scs_role.has_p(^(Int.toString uid),^(Db.qqq role))
              from dual`
	in
	  Db.oneField role_sql = "t"
	end 
      val has_p_cache =	Ns.Cache.memoize role_cache_def has_p'
    in
      fun flushRoleCache() = Ns.Cache.flush role_cache_def
      fun has_p uid (role:role) = has_p_cache (uid,toString role)
    end

    fun has_one_p uid [] = false
      | has_one_p uid (x::xs) = has_p uid x orelse (has_one_p uid xs)

    fun has_one_or_empty_p uid [] = true
      | has_one_or_empty_p uid xs = has_one_p uid xs

    fun getAllRoles user_id =
      (Db.list (fn g => (fromString o g) "abbreviation"))
          `select scs_roles.abbreviation
             from scs_roles, scs_role_rels
            where scs_roles.role_id = scs_role_rels.role_id
              and scs_role_rels.party_id = '^(Int.toString user_id)'`


  end




