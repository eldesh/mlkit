functor InstsX86(structure Labels : ADDRESS_LABELS
		 structure Lvars : LVARS
		 structure Crash : CRASH
		 structure PP : PRETTYPRINT) : INSTS_X86 =
  struct

    fun die s = Crash.impossible("X86Inst." ^ s)

    datatype reg = eax | ebx | ecx | edx | esi | edi | ebp | esp 
                 | ah | cl

    type freg = int

    type label = Labels.label
    datatype lab = 
        DatLab of label      (* For data to propagate across program units *)
      | LocalLab of label    (* Local label inside a block *)
      | NameLab of string    (* For ml strings, jumps to runtime system,
			        jumps to millicode, code label, finish 
			        label, etc. *)
      | MLFunLab of label    (* Labels on ML Functions *)

    fun eq_lab (DatLab label1, DatLab label2) = Labels.eq(label1,label2)
      | eq_lab (LocalLab label1, LocalLab label2) = Labels.eq(label1,label2)
      | eq_lab (NameLab s1, NameLab s2) = s1 = s2
      | eq_lab (MLFunLab label1, MLFunLab label2) = Labels.eq(label1,label2)
      | eq_lab _ = false

    datatype ea = 
        R of reg          (* register *)
      | L of lab          (* label *)
      | LA of lab         (* label address *)
      | I of string       (* immediate *)
      | D of string * reg (* displaced *)

    fun eq_ea (R r, R r') = r=r'
      | eq_ea (I i, I i') = i=i'
      | eq_ea (L l, L l') = eq_lab(l,l')
      | eq_ea (LA l, LA l') = eq_lab(l,l')
      | eq_ea (D p,D p') = p=p'
      | eq_ea _ = false
      
    datatype inst =               (* general instructions *)
        movl of ea * ea
      | leal of ea * ea
      | pushl of ea
      | popl of ea
      | addl of ea * ea
      | subl of ea * ea
      | negl of ea
      | imull of ea * ea
      | notl of ea
      | orl of ea * ea
      | xorl of ea * ea
      | andl of ea * ea
      | andb of ea * ea
      | sarl of ea * ea
      | shrl of ea * ea   (* unsigned *)    
      | sall of ea * ea
      | cmpl of ea * ea
      | btl of ea * ea
      | btrl of ea * ea   (* bit test and reset; sets carry flag *)

      | fstpl of ea       (* store float and pop float stack *)
      | fldl of ea        (* push float onto the float stack *) 
      | fldz              (* push 0.0 onto the float stack *)
      | faddp             (* add st(0) to st(1) and pop *)
      | fsubp             (* subtract st(0) from st(1) and pop *)
      | fmulp             (* multiply st(0) to st(1) and pop *)
      | fdivp             (* divide st(1) with st(0) and pop *) 
      | fcompp            (* compare st(0) and st(1) and pop twice *)
      | fabs              (* st(0) = abs(st(0)) *)
      | fchs              (* st(0) = neg(st(0)) *)
      | fnstsw            (* store float status word *)

      | jmp of ea         (* jump instructions *)
      | jl of lab
      | jg of lab
      | jle of lab        
      | jge of lab
      | je of lab         (* = jz *)
      | jne of lab        (* = jnz *)
      | jc of lab         (* jump on carry *)
      | jnc of lab        (* jump on non-carry *)
      | ja of lab         (* jump if above---unsigned *)
      | jb of lab         (* jump if below---unsigned *)
      | jae of lab        (* jump if above or equal---unsigned *)
      | jbe of lab        (* jump if below or equal---unsigned *)
      | jo of lab         (* jump on overflow *)

      | call of lab       (* C function calls and returns *)
      | ret
      | leave

      | dot_align of int        (* pseudo instructions *)
      | dot_globl of lab
      | dot_text
      | dot_data
      | dot_byte of string
      | dot_long of string
      | dot_double of string
      | dot_string of string
      | dot_size of lab * int
      | lab of lab
      | comment of string

    datatype top_decl =
        FUN of label * inst list
      | FN of label * inst list

    type AsmPrg = {top_decls: top_decl list,
		   init_code: inst list,
		   static_data: inst list}

    fun pr_reg eax = "%eax"
      | pr_reg ebx = "%ebx"
      | pr_reg ecx = "%ecx"
      | pr_reg edx = "%edx"
      | pr_reg esi = "%esi"
      | pr_reg edi = "%edi"
      | pr_reg ebp = "%ebp"
      | pr_reg esp = "%esp"
      | pr_reg ah = "%ah"
      | pr_reg cl = "%cl"

    fun remove_ctrl s = "Lab" ^ String.implode (List.filter Char.isAlphaNum (String.explode s))

    fun pr_lab (DatLab l) = remove_ctrl(Labels.pr_label l)
      | pr_lab (LocalLab l) = "." ^ remove_ctrl(Labels.pr_label l)
      | pr_lab (NameLab s) = s
      | pr_lab (MLFunLab l) = "fun_" ^ remove_ctrl(Labels.pr_label l)

    (* Convert ~n to -n *)
    fun int_to_string i = if i >= 0 then Int.toString i
			  else "-" ^ Int.toString (~i)

    fun pr_ea (R r) = pr_reg r
      | pr_ea (L l) = pr_lab l
      | pr_ea (LA l) = "$" ^ pr_lab l
      | pr_ea (I s) = "$" ^ s
      | pr_ea (D(d,r)) = if d="0" then "(" ^ pr_reg r ^ ")"
			 else d ^ "(" ^ pr_reg r ^ ")"

    fun emit_insts (os, insts: inst list): unit = 
      let fun emit s = TextIO.output(os, s)
	  fun emit_bin (s, (ea1, ea2)) = (emit "\t"; emit s; emit " "; 
					  emit(pr_ea ea1); emit ","; 
					  emit(pr_ea ea2); emit "\n")
	  fun emit_unary(s, ea) = (emit "\t"; emit s; emit " "; emit(pr_ea ea); emit "\n")
	  fun emit_nullary s = (emit "\t"; emit s; emit "\n")
	  fun emit_jump(s,l) = (emit "\t"; emit s; emit " "; emit(pr_lab l); emit "\n")
	  fun emit_inst i =  
	    case i
	      of movl a => emit_bin ("movl", a)
	       | leal a => emit_bin ("leal", a)
	       | pushl ea => emit_unary ("pushl", ea)
	       | popl ea => emit_unary ("popl", ea)
	       | addl a => emit_bin("addl", a)
	       | subl a => emit_bin("subl", a)
	       | negl ea => emit_unary("negl", ea)
	       | imull a => emit_bin("imull", a)
	       | notl ea => emit_unary("notl", ea)
	       | orl a => emit_bin("orl", a)
	       | xorl a => emit_bin("xorl", a)
	       | andl a => emit_bin("andl", a)
	       | andb a => emit_bin("andb", a)
	       | sarl a => emit_bin("sarl", a)
	       | shrl a => emit_bin("shrl", a)
	       | sall a => emit_bin("sall", a)
	       | cmpl a => emit_bin("cmpl", a)
	       | btl a => emit_bin("btl", a)
	       | btrl a => emit_bin("btrl", a)

	       | fstpl ea => emit_unary("fstpl", ea)
	       | fldl ea => emit_unary("fldl", ea)
	       | fldz => emit_nullary "fldz"
	       | faddp => emit_nullary "faddp"
	       | fsubp => emit_nullary "fsubp"
	       | fmulp => emit_nullary "fmulp"
	       | fdivp => emit_nullary "fdivp"
	       | fcompp=> emit_nullary "fcompp"
	       | fabs => emit_nullary "fabs"
	       | fchs => emit_nullary "fchs"
	       | fnstsw => emit_nullary "fnstsw"

	       | jmp (L l) => emit_jump("jmp", l)
	       | jmp ea => (emit "\tjmp *"; emit(pr_ea ea); emit "\n")  
	       | jl l => emit_jump("jl", l)
	       | jg l => emit_jump("jg", l)
	       | jle l => emit_jump("jle", l)
	       | jge l => emit_jump("jge", l)
	       | je l => emit_jump("je", l)
	       | jne l => emit_jump("jne", l)
	       | jc l => emit_jump("jc", l)
	       | jnc l => emit_jump("jnc", l)
	       | ja l => emit_jump("ja", l)
	       | jb l => emit_jump("jb", l)
	       | jae l => emit_jump("jae", l)
	       | jbe l => emit_jump("jbe", l)
               | jo l => emit_jump("jo", l)

	       | call l => emit_jump("call", l)
	       | ret => emit "\tret\n"
	       | leave => emit "\tleave\n"

	       | dot_align i => (emit "\t.align "; emit(Int.toString i); emit "\n")
	       | dot_globl l => (emit ".globl "; emit(pr_lab l); emit "\n")
	       | dot_text => emit ".text\n"
	       | dot_data => emit ".data\n"
	       | dot_byte s => (emit "\t.byte "; emit s; emit "\n")
	       | dot_long s => (emit "\t.long "; emit s; emit "\n")
	       | dot_double s => (emit "\t.double "; emit s; emit "\n")
	       | dot_string s => (emit "\t.string \""; emit s; emit "\"\n")
	       | dot_size (l, i) => (emit "\t.size "; emit(pr_lab l); emit ","; 
				     emit(Int.toString i); emit "\n")
	       | lab l => (emit(pr_lab l); emit":\n")
	       | comment s => (emit " # "; emit s; emit " \n") 
      in app emit_inst insts
      end

    fun emit_topdecl os t =
      case t
	of FUN (l, insts) => emit_insts(os, lab (MLFunLab l)::insts)
	 | FN (l, insts) =>  emit_insts(os, lab (MLFunLab l)::insts)

    (*-----------------------------------------------------------*)
    (* Converting Between General Registers and Precolored Lvars *)
    (* As Used In The Phases Preceeding Code Generation          *)
    (*-----------------------------------------------------------*)
    type lvar = Lvars.lvar
    local
      structure LvarFinMap = Lvars.Map

      val regs = [eax,ebx,ecx,edx,esi,edi,ebp,esp]
      val reg_lvs as [eax_lv,ebx_lv,ecx_lv,edx_lv,esi_lv,edi_lv,ebp_lv,esp_lv] =
	map (fn r => Lvars.new_named_lvar (pr_reg r)) regs
      val map_lvs_to_reg = LvarFinMap.fromList(ListPair.zip(reg_lvs,regs))
    in
      val all_regs_as_lvs = reg_lvs 

      fun is_reg lv = 
	(case LvarFinMap.lookup map_lvs_to_reg lv of
	   SOME reg => true
	 | NONE  => false)

      fun lv_to_reg lv = 
	(case LvarFinMap.lookup map_lvs_to_reg lv of
	   NONE => die "lv_to_reg: lv not a register"
	 | SOME i => i)

      fun reg_to_lv r = 
	case r 
	  of eax => eax_lv | ebx => ebx_lv | ecx => ecx_lv | edx => edx_lv
	   | esi => esi_lv | edi => edi_lv | ebp => ebp_lv | esp => esp_lv
	   | ah => die "reg_to_lv: ah not available for register allocation"
	   | cl => die "reg_to_lv: cl not available for register allocation"

      val reg_args = [eax,ebx,edi]
      val reg_args_as_lvs = map reg_to_lv reg_args
      val reg_res = [edi,ebx,eax] 
      val reg_res_as_lvs = map reg_to_lv reg_res

      val reg_args_ccall = []
      val reg_args_ccall_as_lvs = map reg_to_lv reg_args_ccall
      val reg_res_ccall = [eax] 
      val reg_res_ccall_as_lvs = map reg_to_lv reg_res_ccall

      val callee_save_regs_mlkit = []
      val callee_save_regs_mlkit_as_lvs = map reg_to_lv callee_save_regs_mlkit

      val caller_save_regs_mlkit = [eax,ebx,edi,edx,esi]
      val caller_save_regs_mlkit_as_lvs = map reg_to_lv caller_save_regs_mlkit

      val callee_save_regs_ccall = []
      val callee_save_regs_ccall_as_lvs = map reg_to_lv callee_save_regs_ccall

      (* tmp_reg0 and tmp_reg1 should not be in this list as they are never live across a C call *)
      val caller_save_regs_ccall = [eax,ebx,edi,edx,esi]
      val caller_save_regs_ccall_as_lvs = map reg_to_lv caller_save_regs_ccall
    end

    val tmp_reg0 = ecx
    val tmp_reg1 = ebp

    fun emit ({top_decls: top_decl list,
	       init_code: inst list,
	       static_data: inst list}, filename) =
      let val os : TextIO.outstream = TextIO.openOut filename
      in (emit_insts (os, init_code);
	  app (emit_topdecl os) top_decls;
	  emit_insts (os, static_data);
	  TextIO.closeOut os) handle E => (TextIO.closeOut os; raise E)
      end
    type StringTree = PP.StringTree
    fun layout _ = PP.LEAF "not implemented"
  end
