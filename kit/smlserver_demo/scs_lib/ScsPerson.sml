signature SCS_PERSON =
  sig
    datatype sex = Female | Male

    type person_record = {
      person_id           : int,
      first_names 	  : string,
      last_name		  : string,
      name 		  : string,
      norm_name           : string,
      email		  : string,
      url		  : string,
      cpr                 : string,
      upload_folder_id    : int option, (* folder containing portraits *)
      upload_folder_name  : string option,
      upload_folder_path  : string option,
      may_show_portrait_p : bool
    }

    type profile_record = 
      { party_id       : int,
        profile_tid    : int,
        profile_da     : string,
        profile_en     : string,
	keywords_tid   : int,
	keywords_da    : string,
	keywords_en    : string,
	edit_no        : int,
	last_modified  : Date.date,
	modifying_user : int,
	deleted_p      : bool}

    datatype portrait_type = original | thumb_fixed_height | thumb_fixed_width
    type portrait_record =
      { file_id             : int,
        party_id            : int,
	portrait_type_vid   : int,
        portrait_type_val   : portrait_type,
	filename            : string,
	url                 : string,
	width               : int,
	height              : int,
	bytes               : int,
	official_p          : bool,
	person_name         : string,
	may_show_portrait_p : bool}
      
    val portrait_types_enum_name : string
    val portrait_type_from_DB : string -> portrait_type option
    val portrait_type_to_DB   : portrait_type -> string

    (* Default portraits *)
    val empty_portrait_thumbnail : portrait_record
    val empty_portrait_large : portrait_record

    (* [getPortrait file_id] returns the portrait represented by file_id. *)
    val getPortrait : int -> portrait_record option

    (* [getPortraits user_id] returns a list of portraits uploaded
        for this user. *)
    val getPortraits : int -> portrait_record list

    (* [getPicture pic_type official_p portraits] returns a picture of
       type pic_type that is official or non official depending on
       official_p if exists in the list portraits. *)
    val getPicture : portrait_type -> bool -> portrait_record list -> portrait_record option

    (* [delPortrait db pic] deletes picture pic from
        scs_portraits. *)
    val delPortrait : Db.Handle.db -> portrait_record -> unit

    (* [insPortrait db pic] inserts pic in scs_portraits. *)
    val insPortrait : Db.Handle.db -> portrait_record -> unit

    (* [mayReturnPortrait_p user_id file_id adm_p] returns true if portrait
       represented by file_id may be returned:

         * may_show_portrait_p is true
         * logged in user_id = person_id
         * adm_p is true. *)
    val mayReturnPortrait_p : int -> int -> bool -> bool

      (* [genPortraitHtml thumb large] returns HTML for showing a
          portrait as a thumbnail and when clicked opens a larger
          portrait. *)
    val genPortraitHtml : portrait_record -> portrait_record -> string

    (* [portraitAsHtml (user_id,per:person_record,official_p,adm_p)]
       returns HTML for a portrait. user_id is the logged in user. per
       is the person for which we will show a portrait. If official_p
       is true, then we show the official portrait even if a
       non-official portrait exists. If adm_p is true then the
       portrait is shown even though the person has not allowed his
       portrait to be shown to every one on the Internet/Intranet. 
       
       The rules used to pick portrait:
          1 if may_show_portrait_p = false andalso 
               user_id <> person_id andalso 
               not adm_p then default_picture
          2 non official picture (if official_p = false)
          3 official picture *)
    val portraitAsHtml : int * person_record * bool * bool -> string

    (* [upload_portrait_label] is the root folder in the Scs File Storage
        system where portraits are uploaded. *)
    val upload_root_label : string
  
    (* [max_height] is the maximum height of original picture. If the
        uploaded picture is larger, then it is scaled down. *)
    val max_height   : int

    (* [thumb_height] is the height of a thumbnail. *)
    val thumb_height : int

    (* [uploadPortraitPriv (user_id, per)] returns the priviledge that
        user_id has on uploading pictures to person per. *)
    val uploadPortraitPriv : int * person_record -> ScsFileStorage.priv

    (* [getOrCreateUploadFolderId db prj] returns an id on the folder
        in the file storage area where uploaded portraits to this person
        are stored. This function access and updates the database in
        case no previous folder path and name have been calculated. *)
    val getOrCreateUploadFolderId : Db.Handle.db * person_record -> int

    (* [getPerson user_id] fetches a person from the database *)
    val getPerson : int -> person_record option

    (* [getPersonByExtSource on_what_table on_which_id] fetches a
       person from the database that relates to the external source
       represented by on_what_table and on_which_id. *)
    val getPersonByExtSource : string -> int -> person_record option

    (* [getPersonErr (id,errs)] returns a person record if exists;
       otherwise an error is appended to the error list errs. *)
    val getPersonErr : int * ScsFormVar.errs -> person_record option * ScsFormVar.errs 

    (* [getProfile user_id] fetches a profile from the database. It
       only returns NONE if user_id does not exists in scs_parties. An
       empty profile is created for user_id if no one exists *)
    val getProfile : int -> profile_record option

    (* [getProfileErr (id,errs)] returns a profile record if exists;
       otherwise an error is appended to the error list errs. *)
    val getProfileErr : int * ScsFormVar.errs -> profile_record option * ScsFormVar.errs 

   (* [searchPerson pat keep_del_p] returns a list of persons matching
      the pattern pat. If deleted_p is true then we also search in
      deleted persons *)
    val searchPerson : string -> bool -> person_record list

    (* [name user_id] returns the name found in the database for user
       identified by user_id. Returns "" if no email exists. *)
    val name : int -> string

    (* [email user_id] returns the email found in the database for user
       identified by user_id. Returns "" if no email exists. *)
    val email : int -> string

    (* [nameToHtml name email] returns HTML for a name linking to
        email *)
    val nameToHtml : string * string -> string

    (* [search_form target_url hvs] generates a standard HTML search
       form. The user enter a search expression (e.g., name, security
       id) and either

         * the search expression does not identity any person and an
           info message is shown to the user.

         * the search expression identify exactly one person, and a
           redirect to the page represented by target_url is issued
           with hidden variables hvs and user_id = x where x is
           user_id for the person found.

         * the search expression identity more than one person in
           which case the user is presented a page on which she slects
           the person she seeks. *)
    val search_form: string -> (string*string) list -> quot

    (* [getPersonIdErr fv errs] checks that fv is an integer which can
       be used as a person_id. The database is not checked. See also
       ScsFormVar.sml *)
    val getPersonIdErr : string * ScsFormVar.errs -> int * ScsFormVar.errs

    (* [splitCpr cpr] if cpr is on the form xxxxxxyyyy then the pair
       (xxxxxx,yyyy) is returned. *)
    val splitCpr      : string -> (string*string)

    (* [ppCpr cpr]  if cpr is on the form xxxxxxyyyy then the string
       xxxxxx-yyyy is returned; otherwise the argument is returned. *)
    val ppCpr : string -> string

    (* [makeCprPublic cpr] if cpr in on the form aaaaaabbbb then the
       revised cpr aaaaaaXXXX is returned *)
    val makeCprPublic : string -> string

    (* [cprToDate cpr] if cpr is a valid cpr then a date is returned
       representing the birth date. If cpr is not valid then an
       exception is raised. *)
    val cprToDate     : string -> Date.date

    (* [cprToSex cpr] if cpr is a valid cpr then the sex (either Male
       of Female) is returned. Otherwise an exception is returned. *)
    val cprToSex : string -> sex

    (* [isFemale_p cpr] returns true if the cpr is female. Throws an 
	exception if cpr is invalid *)
    val isFemale_p : string -> bool

    (* [fix_email email] do the following conversions:
         - if email is of form login@it-c.dk => login@itu.dk
         - if email is of form login@it.edu => login@itu.dk
         - if email is of form login => login@itu.dk
     *)
    val fix_email : string -> string
  end

structure ScsPerson :> SCS_PERSON =
  struct
    datatype sex = Female | Male

    type person_record = {
      person_id           : int,
      first_names 	  : string,
      last_name		  : string,
      name 		  : string,
      norm_name           : string,
      email		  : string,
      url		  : string,
      cpr                 : string,
      upload_folder_id    : int option, (* folder containing portraits *)
      upload_folder_name  : string option,
      upload_folder_path  : string option,
      may_show_portrait_p : bool
    }

    type profile_record = 
      { party_id       : int,
        profile_tid    : int,
        profile_da     : string,
        profile_en     : string,
	keywords_tid   : int,
	keywords_da    : string,
	keywords_en    : string,
	edit_no        : int,
	last_modified  : Date.date,
	modifying_user : int,
	deleted_p      : bool}

    datatype portrait_type = original | thumb_fixed_height | thumb_fixed_width
    type portrait_record =
      { file_id             : int,
        party_id            : int,
	portrait_type_vid   : int,
        portrait_type_val   : portrait_type,
	filename            : string,
        url                 : string,
	width               : int,
	height              : int,
	bytes               : int,
	official_p          : bool,
	person_name         : string,
        may_show_portrait_p : bool}

    val portrait_types_enum_name = "scs_portrait_types"
    fun portrait_type_from_DB "orig" = SOME original
      | portrait_type_from_DB "thumb_fixed_height" = SOME thumb_fixed_height
      | portrait_type_from_DB "thumb_fixed_width" = SOME thumb_fixed_width
      | portrait_type_from_DB "" = NONE
      | portrait_type_from_DB s = ScsError.panic `ScsPerson.protrait_type_from_DB: can't convert ^s`
    fun portrait_type_to_DB original = "orig"
      | portrait_type_to_DB thumb_fixed_height = "thumb_fixed_height"
      | portrait_type_to_DB thumb_fixed_width = "thumb_fixed_width"

    (* Virtually download directory *)
    val download_dir = "/scs/person/portrait_download"
    local
      fun mk_url (filename,file_id) = 
	Html.genUrl (download_dir ^ "/" ^ filename) [("file_id",Int.toString file_id)]
      fun f g = 
	let
	  val file_id = (ScsError.valOf o Int.fromString) (g "file_id")
	  val filename = g "filename"
	in
	  {file_id = file_id,
	   party_id = (ScsError.valOf o Int.fromString) (g "party_id"), 
	   portrait_type_vid = (ScsError.valOf o Int.fromString) (g "portrait_type_vid"), 
	   portrait_type_val = (ScsError.valOf o portrait_type_from_DB) (g "portrait_type_val"),
	   filename = filename,
	   url = mk_url (filename,file_id),
	   width = (ScsError.valOf o Int.fromString) (g "width"),
	   height = (ScsError.valOf o Int.fromString) (g "height"),
	   bytes = (ScsError.valOf o Int.fromString) (g "bytes"),
	   official_p = (ScsError.valOf o Db.toBool) (g "official_p"),
	   person_name = g "person_name",
	   may_show_portrait_p = (ScsError.valOf o Db.toBool) (g "may_show_portrait_p")}
	end
      fun portraitSQL from_wh = 
	` select p.file_id,
                 p.party_id,
		 scs_person.name(p.party_id) as person_name,
                 p.portrait_type_vid,
                 scs_enumeration.getVal(p.portrait_type_vid) as portrait_type_val,
		 fs.name as filename,
                 p.width,
                 p.height,
                 p.bytes,
                 p.official_p,
                 party.may_show_portrait_p
	   ` ^^ from_wh
    in
      fun getPortrait file_id =
	SOME (Db.oneRow' f (portraitSQL ` from scs_portraits p, scs_fs_files fs, scs_parties party
		                         where p.file_id = '^(Int.toString file_id)'
                                           and p.file_id = fs.file_id 
                                           and p.party_id = party.party_id`))
	handle _ => NONE
      fun getPortraits user_id =
	ScsError.wrapPanic (Db.list f) (portraitSQL ` from scs_portraits p, scs_fs_files fs, 
					                   scs_parties party
                                                     where p.party_id = '^(Int.toString user_id)'
                                                       and p.file_id = fs.file_id
                                                       and p.party_id = party.party_id`)
    end

    val empty_portrait_thumbnail : portrait_record = 
      { file_id = 0,
        party_id = 0,
	portrait_type_vid = 0,
	portrait_type_val = thumb_fixed_height,
	filename = "empty_portrait_thumbnail.jpg",
	url = download_dir ^ "/empty_portrait_thumbnail.jpg",
	width = 78,
        height = 100,
	bytes = 2841,
	official_p = false,
	person_name = "-",
	may_show_portrait_p = true}
    val empty_portrait_large : portrait_record =
      { file_id = 0,
        party_id = 0,
	portrait_type_vid = 0,
	portrait_type_val = original,
	filename = "empty_portrait_large.jpg",
	url = download_dir ^ "/empty_portrait_large.jpg",
	width = 78,
        height = 100,
	bytes = 2841,
	official_p = false,
	person_name = "-",
	may_show_portrait_p = true}

    fun getPicture pic_type official_p (portraits : portrait_record list) = 
      List.find (fn pic => #portrait_type_val pic = pic_type andalso 
		 #official_p pic = official_p) portraits

    fun delPortrait db (pic : portrait_record) =
      let
	val del_sql = `delete from scs_portraits
                        where file_id = '^(Int.toString (#file_id pic))'`
      in
	ScsError.wrapPanic
	(Db.Handle.dmlDb db) del_sql
      end	

    fun insPortrait db (pic : portrait_record) =
      let
	val ins_sql = `insert into scs_portraits
	                 (file_id,party_id,portrait_type_vid,width,height,bytes,official_p)
                       values
		         ('^(Int.toString (#file_id pic))','^(Int.toString (#party_id pic))',
			  scs_enumeration.getVID(^(Db.qqq portrait_types_enum_name),
						 '^(portrait_type_to_DB (#portrait_type_val pic))'),
                          '^(Int.toString (#width pic))', '^(Int.toString (#height pic))',
			  '^(Int.toString (#bytes pic))', '^(Db.fromBool (#official_p pic))')`
      in
	ScsError.wrapPanic
	(Db.Handle.dmlDb db) ins_sql
      end


    (* TODO: add cache that must be reset when may_show_portrait_p is updated!!! *)
    fun mayReturnPortrait_p user_id file_id adm_p = 
      case getPortrait file_id of
	SOME pic => 
	  #may_show_portrait_p pic orelse
	  user_id = #party_id pic orelse
	  adm_p
      | NONE => false (* No picture so do not return it. *)

    fun genPortraitHtml (thumb:portrait_record) (large:portrait_record) = Quot.toString
	  `<a href="^(#url large)">
	  <img src="^(#url thumb)" width="^(Int.toString (#width thumb))" 
           height="^(Int.toString (#height thumb))" 
	  align="right" alt="^(#person_name thumb)"></a>`
    fun portraitAsHtml (user_id,per:person_record,official_p,adm_p) =
      let
	val default_html = genPortraitHtml empty_portrait_thumbnail empty_portrait_large
	val use_default_p =
	  #may_show_portrait_p per = false andalso
	  user_id <> #person_id per andalso not adm_p
	val portraits = getPortraits (#person_id per)
	val official_html =
	  case (getPicture thumb_fixed_height true portraits,getPicture original true portraits) of
	     (SOME thumb,SOME large) => genPortraitHtml thumb large
	   | _ => default_html
	val non_official_html = 
	  if official_p then
	    official_html
	  else
	    case (getPicture thumb_fixed_height false portraits,getPicture original false portraits) of
	      (SOME thumb,SOME large) => genPortraitHtml thumb large
	    | _ => official_html
      in
	if use_default_p then
	  default_html
	else
	  non_official_html
      end	

    fun uploadPortraitPriv (user_id, per:person_record) =
      if ScsRole.has_p user_id ScsRole.PortraitAdm then ScsFileStorage.admin 
      else if #person_id per = user_id then ScsFileStorage.read_add_delete
	   else if #may_show_portrait_p per then ScsFileStorage.read
		else ScsFileStorage.no_priv

    (* getOrCreateUploadFolderId: check folder_id in scs_parties and
       create a folder if none exists. The folder path is calculated
       as 
          t000/h00/party_id 
       where 
          party_id = thxx (t is for thousand and h for hundred)
    *)
    val upload_root_label = "ScsPersonPortrait"
    val max_height = 600
    val thumb_height = 110

    fun getOrCreateUploadFolderId (db:Db.Handle.db,per:person_record) =
      case #upload_folder_id per of
	SOME id => id
      | NONE =>
	  let
	    val div1000 = Int.div (#person_id per,1000)
	    val div100 = Int.div (#person_id per,100)
	    val folder_path = Int.toString div1000 ^ "/" ^ (Int.toString div100) ^ "/"
	    val folder_name = Int.toString (#person_id per) ^ "-" ^ (ScsFile.encodeFileNameUnix (#norm_name per))
	    val folder_id = 
	      ScsFileStorage.getOrCreateFolderId(db, upload_root_label, folder_path ^ folder_name)
	    val _ = 
	      ScsError.wrapPanic
	      (Db.Handle.dmlDb db)
	      `update scs_parties
                  set ^(Db.setList [("upload_folder_id", Int.toString folder_id),
				    ("upload_folder_path", folder_path),
				    ("upload_folder_name", folder_name)])
                where party_id = '^(Int.toString (#person_id per))'`
	  in
	    folder_id
	  end

    local
      fun f g = {person_id = (ScsError.valOf o Int.fromString) (g "person_id"),
		 first_names = g "first_names",
		 last_name = g "last_name",
		 name = g "name",
		 norm_name = g "norm_name",
		 email = g "email",
		 url = g "url",
		 cpr = g "cpr",
                 upload_folder_id = Int.fromString (g "upload_folder_id"),
		 upload_folder_name = 
  		   if String.size (g "upload_folder_name") = 0 then 
		     NONE 
		   else
		     SOME (g "upload_folder_name"),
		 upload_folder_path = 
  		   if String.size (g "upload_folder_path") = 0 then 
		     NONE 
		   else
		     SOME (g "upload_folder_path"),
		 may_show_portrait_p = (ScsError.valOf o Db.toBool) (g "may_show_portrait_p")}
      fun personSQL from_wh =
	` select p.person_id, p.first_names, p.last_name, 
		 scs_person.name(p.person_id) as name, 
                 p.norm_name,
		 party.email as email,
		 party.url as url,
		 p.security_id as cpr,
                 party.upload_folder_id,
                 party.upload_folder_name,
                 party.upload_folder_path,
                 party.may_show_portrait_p
            ` ^^ from_wh
    in
      fun getPerson user_id = 
	SOME( Db.oneRow' f (personSQL ` from scs_persons p, scs_parties party
                                       where person_id = '^(Int.toString user_id)'
                                         and person_id = party_id`))
	handle _ => NONE
      fun getPersonErr (user_id,errs) =
	case getPerson user_id of
	  NONE => 
	    let
	      val err_msg = [(ScsLang.da,`Personen du s�ger findes ikke.`),
			     (ScsLang.en,`The person you are seeking does not exits.`)]
	    in
	      (NONE,ScsFormVar.addErr(ScsDict.s' err_msg,errs))
	    end
	| p => (p,errs)
      fun getPersonByExtSource on_what_table on_which_id =
	SOME( Db.oneRow' f (personSQL ` from scs_persons p, scs_person_rels r, scs_parties party
                                       where r.on_what_table = ^(Db.qqq on_what_table)
                                         and r.on_which_id = '^(Int.toString on_which_id)'
                                         and r.person_id = p.person_id
                                         and p.person_id = party.party_id`))
	handle _ => NONE
      fun searchPerson pat keep_del_p =
	Db.list f (personSQL 
		   ` from scs_persons p, scs_parties party
                    where (lower(scs_person.name(p.person_id)) like ^(Db.qqq pat)
                       or lower(scs_party.email(p.person_id)) like ^(Db.qqq pat)
		       or p.security_id like ^(Db.qqq pat))
                      and p.deleted_p in (^(if keep_del_p then "'t','f'" else "'f'"))
                      and p.person_id = party.party_id`)
	handle _ => []
    end

    local
      fun f g = {party_id = (ScsError.valOf o Int.fromString) (g "party_id"),
		 profile_tid = (ScsError.valOf o Int.fromString) (g "profile_tid"),
		 profile_da = g "profile_da",
		 profile_en = g "profile_en",
		 keywords_tid = (ScsError.valOf o Int.fromString) (g "keywords_tid"),
		 keywords_da = g "keywords_da",
		 keywords_en = g "keywords_en",
		 edit_no = (ScsError.valOf o Int.fromString) (g "edit_no"),
		 last_modified = (ScsError.valOf o Db.toDate) (g "last_modified"),
		 modifying_user = (ScsError.valOf o Int.fromString) (g "modifying_user"),
		 deleted_p = (ScsError.valOf o Db.toBool) (g "deleted_p")}
      fun profileSQL from_wh =
	` select p.party_id, 
                 p.profile_tid, 
		 scs_text.getText(p.profile_tid,'^(ScsLang.toString ScsLang.da)') 
		   as profile_da,
		 scs_text.getText(p.profile_tid,'^(ScsLang.toString ScsLang.en)') 
		   as profile_en,
                 p.keywords_tid, 
		 scs_text.getText(p.keywords_tid,'^(ScsLang.toString ScsLang.da)') 
		   as keywords_da,
		 scs_text.getText(p.keywords_tid,'^(ScsLang.toString ScsLang.en)') 
		   as keywords_en,
                 p.edit_no, 
                 p.last_modified, 
                 p.modifying_user, 
                 p.deleted_p
            ` ^^ from_wh
    in
      fun getProfile user_id =
	SOME(Db.oneRow' f (profileSQL ` from scs_profiles_w p
			               where p.party_id = '^(Int.toString user_id)'`))
	handle _ => 
	  (* Profile does not exits - so try to insert empty profile *)
	  let
	    val per_opt = getPerson user_id 
	  in
	    case per_opt of
	      NONE => NONE (* User does not exists *)
	    | SOME per => (* User exists so insert empty profile *)
		let
		  (* We set the creating user to be the not logged in user - pretty much arbitrarily *)
                  (* The current user may not be logged in. (e.g., if he comes from Find Person)     *)
		  fun new db =
		    let
		      val profile_tid = Db.Handle.oneFieldDb db `select scs.new_obj_id from dual`
		      val _ = Db.Handle.execSpDb db  
			[`scs_text.updateTextProc(text_id => ^profile_tid,language => 'da',text => '')`,
			  `scs_text.updateTextProc(text_id => ^profile_tid,language => 'en',text => '')`]
		      val keywords_tid = Db.Handle.oneFieldDb db `select scs.new_obj_id from dual`
		      val _ = Db.Handle.execSpDb db  
			[`scs_text.updateTextProc(text_id => ^keywords_tid,language => 'da',text => '')`,
			  `scs_text.updateTextProc(text_id => ^keywords_tid,language => 'en',text => '')`]
		      val empty_profile =
			{party_id = user_id,
			 profile_tid = (ScsError.valOf o Int.fromString) profile_tid,
			 profile_da = "",
			 profile_en = "",
			 keywords_tid = (ScsError.valOf o Int.fromString) keywords_tid,
			 keywords_da = "",
			 keywords_en = "",
			 edit_no = 0,
			 last_modified = ScsDate.now_local(),
			 modifying_user = 0,
			 deleted_p = false}
		      val ins_sql = `insert into scs_profiles 
			(party_id,profile_tid,keywords_tid,edit_no,last_modified,modifying_user)
			values
			('^(Int.toString user_id)','^(profile_tid)','^(keywords_tid)',
			 '0',sysdate,'^(Int.toString ScsLogin.default_id)')` 
		      val _ =Db.Handle.dmlDb db ins_sql
		    in
		      SOME empty_profile
		    end
		in
		  Db.Handle.dmlTrans new
		  handle _ => (Ns.log(Ns.Warning, "Could not create profile for user_id " ^ 
				      Int.toString user_id);
			       NONE)
		end
	  end
      fun getProfileErr (user_id,errs) =
	case getProfile user_id of
	  NONE => 
	    let
	      val err_msg = [(ScsLang.da,`Personen du s�ger findes ikke.`),
			     (ScsLang.en,`The person you are seeking does not exits.`)]
	    in
	      (NONE,ScsFormVar.addErr(ScsDict.s' err_msg,errs))
	    end
	| p => (p,errs)

    end
    fun name user_id =
      Db.oneField `select scs_person.name(person_id)
                     from scs_persons
                    where scs_persons.person_id = '^(Int.toString user_id)'`
      handle Fail _ => ""

    fun email user_id =
      Db.oneField `select scs_party.email(^(Int.toString user_id))
                     from dual`
      handle Fail _ => ""

    fun nameToHtml (name,email) = Quot.toString
      `<a href="mailto:^(email)">^(name)</a>`

    fun search_form target_url hvs =
      ScsWidget.formBox "/scs/person/person_search.sml" 
        [("submit",ScsDict.s [(ScsLang.en,`Search`),(ScsLang.da,`S�g`)])]
        (Html.export_hiddens (("target_url",target_url)::hvs) ^^ 
          (ScsDict.s' [(ScsLang.en,`Search after all persons that matches the pattern you type in below. 
			            Several fields related to a person are searched 
                                    including name, security number and email.`),
		       (ScsLang.da,`S�g efter alle personer som matcher det m�nster du indtaster nedenfor.
                                    Der s�ges i flere felter, bl.a. navn, cpr nummer og email.`)]) ^^ `<p>` ^^
       (ScsWidget.tableWithTwoCols[(ScsDict.s' [(ScsLang.en,`Search pattern:`),
						(ScsLang.da,`S�gem�nster`)],ScsWidget.intext 40 "pat")]))

   (* Check for form variables *)
    fun getPersonIdErr (fv,errs) = ScsFormVar.getIntErr(fv,"Person id",errs)

    fun splitCpr cpr = (String.substring (cpr,0,6),String.substring (cpr,6,4))

    fun ppCpr cpr =
      let 
	val (x,y) = splitCpr cpr
      in
	x ^ "-" ^ y
      end
    handle _ => cpr

    fun makeCprPublic cpr =
      let
	val (cpr1,_) = splitCpr cpr
      in
	cpr1 ^ "-xxxx"
      end

    fun cprToDate cpr =
      let
	val (cpr1,_) = splitCpr cpr
	val day = Option.valOf(Int.fromString(String.substring(cpr1,0,2)))
	val mth = Option.valOf(Int.fromString(String.substring(cpr1,2,2)))
	val year = Option.valOf(Int.fromString(String.substring(cpr1,4,2)))
	val year = if year < 20 then 2000 + year else 1900 + year
      in
	ScsDate.genDate(day,mth,year)
      end

    fun cprToSex cpr =
      case String.substring(cpr,9,1) of
	"1" => Male
      | "3" => Male
      | "5" => Male
      | "7" => Male
      | "9" => Male
      | _ => Female

    (* do the following conversions:
         - if email is of form login@itu.dk => login@it-c.dk
         - if email is of form login@it.edu => login@it-c.dk
         - if email is of form login => login@it-c.dk
     *)
    fun fix_email email =
      let
	val email = ScsString.lower email
	val regExpExtract = RegExp.extract o RegExp.fromString
      in
	case regExpExtract "([a-z][a-z0-9\\-]*)@(it-c.dk|it.edu)" email of
	  SOME [l,e] => l ^ "@itu.dk"
	| _ => 
	    (case regExpExtract "([a-z][a-z0-9\\-]*)" email of
	       SOME [l] => l ^ "@itu.dk"
	     | _ => email)
      end
    (* Test code for fix_email
       fun try s =
         print (s ^ " = " ^ (fix_email s) ^ "\n")
       val _ =
         (try "nh";
          try "hanne@ruc.dk";
          try "nh@it-c.dk";
          try "nh@itu.dk";
          try "nh@it.edu";
          try "nh@diku.dk")
       handle Fail s => print s*)

    fun isFemale_p cpr = 
      cprToSex cpr = Female

  end