local
  ../lib/Quot.sml
  local
    ../lib/NsBasics.sml
    ../lib/NS_SET.sml
    ../lib/NsSet.sml
    ../lib/NsInfo.sml
    ../lib/NS_DB.sml
    ../lib/DbFunctor.sml
  in
    ../lib/NS.sml
    ../lib/Ns.sml  
    ../lib/Db.sml
    ../lib/DbClob.sml
  end
  ../lib/HTML.sml
  ../lib/Html.sml
  ../scs_lib/ScsString.sml
  ../scs_lib/SCS_SECURITY.sml
  ../scs_lib/ScsSecurity.sml
  ../scs_lib/ScsLang.sml
  ../scs_lib/SCS_PAGE.sml
  ../scs_lib/ScsLogin.sml
  ../scs_lib/ScsDate.sml
  ../scs_lib/ScsDict.sml
  ../scs_lib/ScsPage.sml
  ../scs_lib/ScsAudit.sml
  ../scs_lib/ScsError.sml
  ../scs_lib/ScsFile.sml
  ../scs_lib/ScsDb.sml
  ../scs_lib/ScsWidget.sml
  ../scs_lib/ScsPrint.sml
  ../scs_lib/ScsReal.sml
  ../scs_lib/ScsList.sml
  ../lib/MSP.sml
  ../lib/Msp.sml
  ../scs_lib/ScsFormVar.sml

  ../scs_lib/ScsGlobal.sml

  rating/RatingUtil.sml
in
 [
  rating/index.sml
  rating/add.sml
  rating/add0.sml
  rating/wine.sml
  employee/update.sml
  employee/search.sml
  time_of_day.sml
  cache.sml
  cache_lookup.sml
  cache_add.sml
  guess.sml
  counter.sml
  temp.sml
  recipe.sml
  hej.sml
  yellow.sml
  fib.sml
  life.sml
  hello.sml
  show.sml
  h1.sml
  hello.msp
  calendar.msp
  test.msp
  index.sml
  logtofile.msp
  fileindex.msp
  dir.msp
  friends.msp
  friends_add_form.msp
  friends_add.msp
  server.sml
  mail_form.sml
  mail.sml
  mul.msp
  show_cookies.sml
  auth_example.sml

  cs_form.sml
  cs_add.sml
  cs_upd.sml
  cs_const.sml

  ug.sml
  currency.sml
  currency_cache.sml
  regexp.sml
  cookie.sml
  cookie_set.sml
  cookie_delete.sml

  formvar.sml
  formvar_chk.sml
  url_desc.sml

  email_form.sml
  email_sent.sml

  (* Scs Dictionary *)
  scs/admin/dict/dict_form.sml
  scs/admin/dict/dict_entry_form.sml

  (* ScsPrint *)
  scs/print/scs-print.sml
  scs/print/log.sml
  scs/print/show_doc.sml
  scs/print/toggle_deleted.sml

  (* ScsAuthentication *)
  auth_form.sml
  auth.sml
  auth_logout.sml

  (* SCS Auditing *)
  scs/admin/audit/audit_tables.sml
  scs/audit/audit_trail.sml
  scs/audit/audit_table.sml
  scs/audit/audit_row.sml

 ]
end