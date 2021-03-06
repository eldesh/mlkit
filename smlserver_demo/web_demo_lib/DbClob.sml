signature DB_CLOB =
  sig
    (* [insert q] return fresh clob_id and inserts in db_clob table *)
    val insert    : quot -> string                    

    (* [insert_fn q] lamba version of insert to use as part of a
       larger transaction *)
    val insert_fn : quot -> (Db.Handle.db -> string)  

    (* [update clob_id q] update the clob identified as clob_id with
       quotation q *)
    val update    : string -> quot -> unit            

    (* [update_fn clob_id q] lambda version of update to use as part
       of a larger transaction *)
    val update_fn : string -> quot -> (Db.Handle.db -> unit) 

    (* [select clob_id] select a clob given a clob_id *)
    val select    : string -> quot                    

    (* [select_fn clob_id] lamda version of select - to use in a
       larger transaction *)
    val select_fn : string -> (Db.Handle.db -> quot)  

    (* [delete clob_id] delete clob given a clob_id *)
    val delete    : string -> unit                    

    (* [delete_fn clob_id] lambda version of delete - to use in a
       larger transaction *)
    val delete_fn : string -> (Db.Handle.db -> unit)  

    (* [gToStringOpt g field_name] is used to extract text from 
       database (clob) fields that are nullable. returns (SOME clob_text)
       if g field_name contains an integer *)
    val gToStringOpt : (string->string) -> string -> string option
  end

structure DbClob :> DB_CLOB =
  struct
    fun insert_fn' (clob_id:string) (q:quot) : Db.Handle.db -> string = 
      let
        fun split s = if Substring.size s <= 4000
			then [Substring.string s]
		      else 
			let 
			  val (s1,s2) = Substring.splitAt(s,4000)
			in
			  Substring.string s1 :: split s2
			end
	val strs = split (Substring.full (Quot.toString q))
      in
	fn db =>
	    (List.foldl (fn (s,idx) => 
			 (Db.Handle.dmlDb db `insert into db_clob (clob_id,idx,text) 
                                              values (^(Db.valueList[clob_id,Int.toString idx,s]))`;
			  idx+1)) 0 strs;
	     clob_id)
      end
    fun insert_fn q = insert_fn' (Int.toString (Db.seqNextval "db_clob_id_seq")) q
    val insert = Db.Handle.dmlTrans o insert_fn

    fun delete_fn (clob_id : string) : Db.Handle.db -> unit =
      fn db => Db.Handle.dmlDb db `delete from db_clob where clob_id = ^(Db.qqq clob_id)`
    fun delete clob_id = Db.Handle.dmlTrans (delete_fn clob_id)

    fun update_fn clob_id q = fn db => (delete_fn clob_id db; insert_fn' clob_id q db; ())
    fun update clob_id q = Db.Handle.dmlTrans (update_fn clob_id q)

    fun select_fn clob_id =
      fn db =>
      Db.Handle.foldDb db 
      (fn (g,acc) => acc ^^ `^(g "text")`) `` `select text from db_clob  
                                               where clob_id=^(Db.qqq clob_id)
                                               order by idx`
    fun select clob_id = Db.Handle.wrapDb (select_fn clob_id)

    fun gToStringOpt    g field_name = case Int.fromString( g field_name ) of 
        SOME cid => SOME (Quot.toString (select (g field_name)))
      | NONE	 => NONE

  end
