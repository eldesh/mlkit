SHELL=/bin/sh

KITVERSION=4.1.5

ARCH-OS=x86-linux
#ARCH-OS=x86-bsd

srcdir=.
top_srcdir=.
prefix=/usr/local


INSTDIR=$(DESTDIR)${prefix}/mlkit
INSTDIR_KAM=$(DESTDIR)${prefix}/mlkit_kam
INSTDIR_BARRY=$(DESTDIR)${prefix}/barry
INSTDIR_SMLSERVER=$(DESTDIR)${prefix}/smlserver
RPMDIR=/usr/src/rpm
#RPMDIR=/usr/src/redhat

# Some commands
#MKDIR=mkdir -p
MKDIR=$(top_srcdir)/mkinstalldirs
#INSTALL=cp -p
INSTALL=/usr/bin/install -c



CLEAN=rm -rf MLB PM CM *~ .\#*

.PHONY: smlserver install
mlkit:
	$(MKDIR) bin
	cd src; $(MAKE)

mlkit_kam:
	$(MKDIR) bin
	cd src; $(MAKE) mlkit_kam

smlserver:
	$(MKDIR) bin
	cd src; $(MAKE) smlserver

barry:
	$(MKDIR) bin
	cd src; $(MAKE) barry

clean:
	$(CLEAN) bin run mlkit.spec smlserver.spec
	cd basis; $(MAKE) clean
	cd doc/manual; $(MAKE) clean
	cd kitlib; $(CLEAN) run
	cd ml-yacc-lib; $(CLEAN)
	cd kitdemo; $(CLEAN) run */PM */*~
	cd test; $(MAKE) clean
	cd test_dev; $(CLEAN) run *.out *.log
	cd src; $(MAKE) clean
	cd smlserver_demo; $(CLEAN) sources.pm nsd.mael.tcl
	cd smlserver_demo/lib; $(CLEAN)
	cd smlserver_demo/demo; $(CLEAN) 
	cd smlserver_demo/demo/rating; $(CLEAN) 
	cd smlserver_demo/demo/employee; $(CLEAN) 
	cd smlserver_demo/demo/link; $(CLEAN) 
	cd smlserver_demo/demo_lib; $(CLEAN) 
	cd smlserver_demo/demo_lib/orasql; $(CLEAN) 
	cd smlserver_demo/demo_lib/pgsql; $(CLEAN) 
	cd smlserver_demo/scs_lib; $(CLEAN) 
	cd smlserver_demo/scs_lib/pgsql; $(CLEAN)
	cd smlserver_demo/log; rm -f server.log access* nspid*
	cd smlserver_demo/www; $(CLEAN)
	cd smlserver_demo/www/demo; $(CLEAN)
	cd smlserver_demo/www/demo/rating; $(CLEAN)
	cd smlserver_demo/www/demo/link; $(CLEAN)
	cd smlserver_demo/www/demo/employee; $(CLEAN)
	cd smlserver; $(CLEAN)
	cd smlserver/xt; $(CLEAN)
	cd smlserver/xt/demolib; $(CLEAN)
	cd smlserver/xt/libxt; $(CLEAN)
	cd smlserver/xt/www; $(CLEAN)

clean_mlb:
	rm -rf MLB */MLB */*/MLB */*/*/MLB */*/*/*/MLB */*/*/*/*/MLB */*/*/*/*/*/MLB 

tgz_export:
	cd ..; rm -rf mlkit-$(KITVERSION) mlkit-$(KITVERSION).tgz
	cd ..; cvs -d linux.it.edu:/cvsroot -q export -D now -d mlkit-$(KITVERSION) mlkit/kit
	cd ..; tar czf mlkit-$(KITVERSION).tgz mlkit-$(KITVERSION)
	cd ..; rm -rf mlkit-$(KITVERSION)

tgz:
	cd ..; rm -rf mlkit-$(KITVERSION) mlkit-$(KITVERSION).tgz
	cd ..; cp -d -f -p -R kit mlkit-$(KITVERSION)
	cd ../mlkit-$(KITVERSION); $(MAKE) clean
	cd ../mlkit-$(KITVERSION); rm -rf test_dev
	cd ../mlkit-$(KITVERSION); rm -rf CVS */CVS */*/CVS */*/*/CVS */*/*/*/CVS */*/*/*/*/CVS */*/*/*/*/*/CVS
	cd ../mlkit-$(KITVERSION); rm -rf .cvsignore */.cvsignore */*/.cvsignore \
           */*/*/.cvsignore */*/*/*/.cvsignore */*/*/*/*/.cvsignore \
           */*/*/*/*/*/.cvsignore
	cd ..; tar czf mlkit-$(KITVERSION).tgz mlkit-$(KITVERSION)
	cd ..; rm -rf mlkit-$(KITVERSION)

tgz_smlserver:
	cd ..; rm -rf smlserver-$(KITVERSION) smlserver-$(KITVERSION).tgz
	cd ..; cp -d -f -p -R kit smlserver-$(KITVERSION)
	cd ../smlserver-$(KITVERSION); $(MAKE) clean
	cd ../smlserver-$(KITVERSION); rm -rf test_dev
	cd ../smlserver-$(KITVERSION); rm -rf CVS */CVS */*/CVS */*/*/CVS */*/*/*/CVS */*/*/*/*/CVS */*/*/*/*/*/CVS
	cd ../smlserver-$(KITVERSION); rm -rf .cvsignore */.cvsignore */*/.cvsignore \
           */*/*/.cvsignore */*/*/*/.cvsignore */*/*/*/*/.cvsignore \
           */*/*/*/*/*/.cvsignore
	cd ..; tar czf smlserver-$(KITVERSION).tgz smlserver-$(KITVERSION)
	cd ..; rm -rf smlserver-$(KITVERSION)

%.spec: %.spec.in
	sed -e "s+@VERSION@+$(KITVERSION)+g" < $< > $@

rpm_smlserver: smlserver.spec
	# assume that ``make tgz_smlserver'' has been run 
	# as a user other than root!
	cp -f ../smlserver-$(KITVERSION).tgz $(RPMDIR)/SOURCES/
	cp -f smlserver.spec $(RPMDIR)/SPECS/smlserver-$(KITVERSION).spec
	(cd $(RPMDIR)/SPECS; rpm -ba smlserver-$(KITVERSION).spec)

rpm: mlkit.spec
	# assume that ``make tgz'' has been run 
	# as a user other than root!
	cp -f ../mlkit-$(KITVERSION).tgz $(RPMDIR)/SOURCES/
	cp -f mlkit.spec $(RPMDIR)/SPECS/mlkit-$(KITVERSION).spec
	(cd $(RPMDIR)/SPECS; rpm -ba mlkit-$(KITVERSION).spec)

install_top:
	$(MKDIR) $(INSTDIR)
	$(MKDIR) $(INSTDIR)/bin
	$(MKDIR) $(INSTDIR)/doc
	$(MKDIR) $(INSTDIR)/ml-yacc-lib
	$(MKDIR) $(INSTDIR)/basis
	$(MKDIR) $(INSTDIR)/kitlib
	$(MKDIR) $(INSTDIR)/kitdemo
	$(MKDIR) $(INSTDIR)/kitdemo/utils
	$(INSTALL) version $(INSTDIR)
	$(INSTALL) copyright $(INSTDIR)
	$(INSTALL) README $(INSTDIR)
	$(INSTALL) Makefile $(INSTDIR)
	$(INSTALL) mkinstalldirs $(INSTDIR)
	$(INSTALL) kitdemo/*.{sml,mlb,c} $(INSTDIR)/kitdemo 
	$(INSTALL) kitdemo/utils/*.{sml,mlb} $(INSTDIR)/kitdemo/utils 
	$(INSTALL) ml-yacc-lib/*.{sml,mlb} $(INSTDIR)/ml-yacc-lib
	$(INSTALL) basis/*.{sml,mlb} $(INSTDIR)/basis

install_runtime:
	$(INSTALL) bin/runtimeSystem.a $(INSTDIR)/bin
	$(INSTALL) bin/runtimeSystemProf.a $(INSTDIR)/bin
	$(INSTALL) bin/runtimeSystemGC.a $(INSTDIR)/bin
	$(INSTALL) bin/runtimeSystemGCProf.a $(INSTDIR)/bin
	$(INSTALL) bin/runtimeSystemGenGC.a $(INSTDIR)/bin
	$(INSTALL) bin/runtimeSystemGenGCProf.a $(INSTDIR)/bin
	$(INSTALL) bin/runtimeSystemGCTP.a $(INSTDIR)/bin
	$(INSTALL) bin/runtimeSystemGCTPProf.a $(INSTDIR)/bin
	$(INSTALL) bin/runtimeSystemTag.a $(INSTDIR)/bin
	$(INSTALL) bin/rp2ps $(INSTDIR)/bin

install: install_top install_runtime
	$(INSTALL) bin/mlkit.$(ARCH-OS) $(INSTDIR)/bin
	$(INSTALL) doc/manual/mlkit.pdf $(INSTDIR)/doc
#
# The following is also done in the %post section in the rpm file, 
# because the --prefix option to rpm can change the installation 
# directory! 
#
	echo '#!/bin/sh' > $(INSTDIR)/bin/mlkit
	echo -e '$(INSTDIR)/bin/mlkit.$(ARCH-OS) $(INSTDIR) $$*' >> $(INSTDIR)/bin/mlkit
	chmod a+x $(INSTDIR)/bin/mlkit

# The following is necessary if you want to either run kittester
# or bootstrap the Kit.

install_test:
	$(MKDIR) $(INSTDIR)/test
	$(MKDIR) $(INSTDIR)/test/mlyacc $(INSTDIR)/test/ray $(INSTDIR)/test/nucleic $(INSTDIR)/test/danwang
	$(MKDIR) $(INSTDIR)/test/barnes-hut $(INSTDIR)/test/logic
	$(MKDIR) $(INSTDIR)/test/DATA $(INSTDIR)/test/LEXGEN_DATA $(INSTDIR)/test/VLIW_DATA
	$(MKDIR) $(INSTDIR)/test/ray/DATA $(INSTDIR)/test/mlyacc/DATA
	$(INSTALL) test/Makefile test/Makefile_bootstrap $(INSTDIR)/test
	$(INSTALL) test/Makefile test/*.{tst,sml,mlb,out.ok,log.ok,txt,dat,c} $(INSTDIR)/test
	$(INSTALL) test/README $(INSTDIR)/test 
	$(INSTALL) test/DATA/*.{gml,sml} $(INSTDIR)/test/DATA
	$(INSTALL) test/LEXGEN_DATA/*.{lex,sml} $(INSTDIR)/test/LEXGEN_DATA 
	$(INSTALL) test/VLIW_DATA/*.s $(INSTDIR)/test/VLIW_DATA 
	$(INSTALL) test/ray/DATA/TEST $(INSTDIR)/test/ray/DATA
	$(INSTALL) test/ray/input test/ray/README test/ray/output test/ray/load test/ray/*.{sml,mlb} $(INSTDIR)/test/ray
	$(INSTALL) test/mlyacc/DATA/*.{grm,sml,sig} $(INSTDIR)/test/mlyacc/DATA
	$(INSTALL) test/mlyacc/*.{sig,sml,mlb} $(INSTDIR)/test/mlyacc
	$(INSTALL) test/nucleic/MAIL test/nucleic/*.{sml,mlb,tex,bbl} $(INSTDIR)/test/nucleic
	$(INSTALL) test/danwang/*.{sml,sig,mlb} $(INSTDIR)/test/danwang
	$(INSTALL) test/barnes-hut/*.{sml,mlb} test/barnes-hut/load test/barnes-hut/README $(INSTDIR)/test/barnes-hut
	$(INSTALL) test/logic/*.{sml,mlb} $(INSTDIR)/test/logic
	cd $(INSTDIR)/test; ln -sf README testlink
	cd $(INSTDIR)/test; ln -sf testcycl testcycl
	cd $(INSTDIR)/test; ln -sf exists.not testbadl
	cd $(INSTDIR)/test; echo -e 'hardlinkA' >> hardlinkA
	cd $(INSTDIR)/test; ln -f hardlinkA hardlinkB

install_src:
	$(MKDIR) $(INSTDIR)/src
	$(MKDIR) $(INSTDIR)/src/Common $(INSTDIR)/src/Compiler $(INSTDIR)/src/Manager $(INSTDIR)/src/Pickle 
	$(MKDIR) $(INSTDIR)/src/CUtils $(INSTDIR)/src/Edlib $(INSTDIR)/src/Parsing $(INSTDIR)/src/Runtime 
	$(MKDIR) $(INSTDIR)/src/SMLserver $(INSTDIR)/src/Tools
	$(MKDIR) $(INSTDIR)/src/SMLserver/apache
	$(MKDIR) $(INSTDIR)/src/SMLserver/apache/test
	$(MKDIR) $(INSTDIR)/src/Common/EfficientElab
	$(MKDIR) $(INSTDIR)/src/Compiler/Backend $(INSTDIR)/src/Compiler/Lambda $(INSTDIR)/src/Compiler/Regions
	$(MKDIR) $(INSTDIR)/src/Compiler/Backend/Barry $(INSTDIR)/src/Compiler/Backend/Dummy $(INSTDIR)/src/Compiler/Backend/KAM
	$(MKDIR) $(INSTDIR)/src/Compiler/Backend/X86
	$(MKDIR) $(INSTDIR)/src/Tools/Benchmark $(INSTDIR)/src/Tools/GenOpcodes $(INSTDIR)/src/Tools/MlbMake $(INSTDIR)/src/Tools/Rp2ps
	$(MKDIR) $(INSTDIR)/src/Tools/Tester
	$(MKDIR) $(INSTDIR)/src/heap2exec
	$(INSTALL) src/Makefile src/*.{mlb,sml,in} $(INSTDIR)/src
	$(INSTALL) src/Common/*.{mlb,sml} $(INSTDIR)/src/Common
	$(INSTALL) src/Common/EfficientElab/*.sml $(INSTDIR)/src/Common/EfficientElab
	$(INSTALL) src/Compiler/*.{mlb,sml} $(INSTDIR)/src/Compiler
	$(INSTALL) src/Compiler/Lambda/*.sml $(INSTDIR)/src/Compiler/Lambda
	$(INSTALL) src/Compiler/Regions/*.sml $(INSTDIR)/src/Compiler/Regions
	$(INSTALL) src/Compiler/Backend/*.sml $(INSTDIR)/src/Compiler/Backend
	$(INSTALL) src/Compiler/Backend/Barry/*.sml $(INSTDIR)/src/Compiler/Backend/Barry
	$(INSTALL) src/Compiler/Backend/Dummy/*.sml $(INSTDIR)/src/Compiler/Backend/Dummy
	$(INSTALL) src/Compiler/Backend/KAM/*.{sml,spec} $(INSTDIR)/src/Compiler/Backend/KAM
	$(INSTALL) src/Compiler/Backend/X86/*.sml $(INSTDIR)/src/Compiler/Backend/X86
	$(INSTALL) src/Manager/*.{sml,mlb} $(INSTDIR)/src/Manager
	$(INSTALL) src/Pickle/*.{sml,sig,mlb} $(INSTDIR)/src/Pickle
	$(INSTALL) src/CUtils/Makefile src/CUtils/*.{c,h} $(INSTDIR)/src/CUtils
	$(INSTALL) src/Edlib/Makefile src/Edlib/*.{sml,mlb} $(INSTDIR)/src/Edlib
	$(INSTALL) src/Parsing/*.{sml,sig,grm,lex,desc} $(INSTDIR)/src/Parsing
	$(INSTALL) src/Runtime/Makefile src/Runtime/*.{c,h} $(INSTDIR)/src/Runtime
	$(INSTALL) src/SMLserver/Makefile src/SMLserver/*.{c,h} $(INSTDIR)/src/SMLserver
	$(INSTALL) src/SMLserver/apache/Makefile.in src/SMLserver/apache/Makefile src/SMLserver/apache/README $(INSTDIR)/src/SMLserver/apache
	$(INSTALL) src/SMLserver/apache/Notes src/SMLserver/apache/*.{c,h,in} $(INSTDIR)/src/SMLserver/apache
	$(INSTALL) src/SMLserver/apache/test/Makefile src/SMLserver/apache/test/*.{c,txt} $(INSTDIR)/src/SMLserver/apache/test
	$(INSTALL) src/Tools/Benchmark/*.{sml,cm} src/Tools/Benchmark/Makefile $(INSTDIR)/src/Tools/Benchmark
	$(INSTALL) src/Tools/GenOpcodes/*.{sml,cm} src/Tools/GenOpcodes/Makefile $(INSTDIR)/src/Tools/GenOpcodes
	$(INSTALL) src/Tools/MlbMake/*.{sml,cm,mlb} src/Tools/MlbMake/Makefile $(INSTDIR)/src/Tools/MlbMake
	$(INSTALL) src/Tools/Rp2ps/*.{c,h} src/Tools/Rp2ps/Makefile $(INSTDIR)/src/Tools/Rp2ps
	$(INSTALL) src/Tools/Tester/*.{sml,cm} src/Tools/Tester/Makefile $(INSTDIR)/src/Tools/Tester
	$(INSTALL) src/heap2exec/heap2exec src/heap2exec/README src/heap2exec/run.$(ARCH-OS) $(INSTDIR)/src/heap2exec

bootstrap0: install_test install_src
	$(INSTALL) bin/kittester.$(ARCH-OS) $(INSTDIR)/bin
	echo -e 'sml @SMLload=$(INSTDIR)/bin/kittester.$(ARCH-OS) $$*' >> $(INSTDIR)/bin/kittester
	chmod a+x $(INSTDIR)/bin/kittester

bootstrap_first: install bootstrap0

bootstrap_next_build:
	cd src; $(MAKE) genopcodes
	cd src; $(MAKE) version
	export SML_LIB=$(shell pwd); cd src/Compiler; ../../bin/mlkit -gc native.mlb

bootstrap_next_install: 
	$(MAKE) install_top
	$(INSTALL) doc/mlkit.pdf $(INSTDIR)/doc
	$(MAKE) install_runtime
	$(INSTALL) src/Compiler/run $(INSTDIR)/bin/mlkit.img
	echo -e '#!/bin/sh' >> $(INSTDIR)/bin/mlkit
	echo -e '$(INSTDIR)/bin/mlkit.img $(RUNTIME_FLAGS) $(INSTDIR) $$*' >> $(INSTDIR)/bin/mlkit
	chmod a+x $(INSTDIR)/bin/mlkit
	$(INSTALL) bin/kittester.$(ARCH-OS) $(INSTDIR)/bin
	echo -e 'sml @SMLload=$(INSTDIR)/bin/kittester.$(ARCH-OS) $$*' >> $(INSTDIR)/bin/kittester
	chmod a+x $(INSTDIR)/bin/kittester
	$(MAKE) install_test
	$(MAKE) install_src

bootstrap_next: 
	$(MAKE) bootstrap_next_build
	$(MAKE) bootstrap_next_install


# The following is obsolete!!
bootstrap_kam: install_kam bootstrap0

install_kam:
	rm -rf $(INSTDIR_KAM)
	$(MKDIR) $(INSTDIR_KAM)
	$(MKDIR) $(INSTDIR_KAM)/bin
	$(MKDIR) $(INSTDIR_KAM)/doc
	$(INSTALL) bin/mlkit_kam.$(ARCH-OS) $(INSTDIR_KAM)/bin
	$(INSTALL) bin/kam $(INSTDIR_KAM)/bin
	$(INSTALL) version $(INSTDIR)
	$(INSTALL) copyright $(INSTDIR_KAM)
	$(INSTALL) README $(INSTDIR_KAM)
	$(INSTALL) -R kitdemo $(INSTDIR_KAM)/kitdemo 
	$(INSTALL) -R ml-yacc-lib $(INSTDIR_KAM)/ml-yacc-lib
	$(INSTALL) -R basis $(INSTDIR_KAM)/basis
	$(INSTALL) doc/manual/mlkit.pdf $(INSTDIR_KAM)/doc
	chown -R `whoami`.`whoami` $(INSTDIR_KAM)
	chmod -R ug+rw $(INSTDIR_KAM)
	chmod -R o+r $(INSTDIR_KAM)

	echo '#!/bin/sh' > $(INSTDIR_KAM)/bin/mlkit_kam
	echo -e '$(INSTDIR_KAM)/bin/mlkit_kam.$(ARCH-OS) $(INSTDIR_KAM) $$*' >> $(INSTDIR_KAM)/bin/mlkit_kam
	chmod a+x $(INSTDIR_KAM)/bin/mlkit_kam
#	rm -f /usr/bin/mlkit_kam
#	cp -f -p $(INSTDIR_KAM)/bin/mlkit_kam /usr/bin/mlkit_kam

install_barry:
	rm -rf $(INSTDIR_BARRY)
	$(MKDIR) $(INSTDIR_BARRY)
	$(MKDIR) $(INSTDIR_BARRY)/bin
	$(MKDIR) $(INSTDIR_BARRY)/doc
	$(INSTALL) bin/barry.$(ARCH-OS) $(INSTDIR_BARRY)/bin
	$(INSTALL) copyright $(INSTDIR_BARRY)
	$(INSTALL) README $(INSTDIR_BARRY)
	$(INSTALL) README_BARRY $(INSTDIR_BARRY)
	$(INSTALL) -R kitdemo $(INSTDIR_BARRY)/kitdemo 
	$(INSTALL) -R ml-yacc-lib $(INSTDIR_BARRY)/ml-yacc-lib
	$(INSTALL) -R basis $(INSTDIR_BARRY)/basis
	$(INSTALL) doc/manual/mlkit.pdf $(INSTDIR_BARRY)/doc
	chown -R `whoami`.`whoami` $(INSTDIR_BARRY)
	chmod -R ug+rw $(INSTDIR_BARRY)
	chmod -R o+r $(INSTDIR_BARRY)

	echo '#!/bin/sh' > $(INSTDIR_BARRY)/bin/barry
	echo -e '$(INSTDIR_BARRY)/bin/barry.$(ARCH-OS) $(INSTDIR_BARRY) $$*' >> $(INSTDIR_BARRY)/bin/barry
	chmod a+x $(INSTDIR_BARRY)/bin/barry
	rm -f /usr/bin/barry
	cp -f -p $(INSTDIR_BARRY)/bin/barry /usr/bin/barry

install_smlserver:
	rm -rf $(INSTDIR_SMLSERVER)
	$(MKDIR) $(INSTDIR_SMLSERVER)
	$(MKDIR) $(INSTDIR_SMLSERVER)/bin
	$(MKDIR) $(INSTDIR_SMLSERVER)/doc
	$(INSTALL) bin/smlserverc.$(ARCH-OS) $(INSTDIR_SMLSERVER)/bin
	$(INSTALL) src/SMLserver/nssml.so $(INSTDIR_SMLSERVER)/bin
	$(INSTALL) copyright $(INSTDIR_SMLSERVER)
	$(INSTALL) README $(INSTDIR_SMLSERVER)
	$(INSTALL) README_SMLSERVER $(INSTDIR_SMLSERVER)
	$(INSTALL) NEWS_SMLSERVER $(INSTDIR_SMLSERVER)
	$(INSTALL) -R smlserver/xt $(INSTDIR_SMLSERVER)/xt
	$(INSTALL) -R smlserver_demo $(INSTDIR_SMLSERVER)/smlserver_demo 
	$(INSTALL) -R basis $(INSTDIR_SMLSERVER)/basis
#	$(INSTALL) doc/manual/mlkit.pdf $(INSTDIR_SMLSERVER)/doc
	$(INSTALL) doc/smlserver.pdf $(INSTDIR_SMLSERVER)/doc
	chown -R `whoami`.`whoami` $(INSTDIR_SMLSERVER)
	chmod -R ug+rw $(INSTDIR_SMLSERVER)
	chmod -R o+r $(INSTDIR_SMLSERVER)
#
# The following is also done in the %post section in the rpm file, 
# because the --prefix option to rpm can change the installation 
# directory! 
#
	echo '#!/bin/sh' > $(INSTDIR_SMLSERVER)/bin/smlserverc
	echo -e '$(INSTDIR_SMLSERVER)/bin/smlserverc.$(ARCH-OS) $(INSTDIR_SMLSERVER) $$*' >> $(INSTDIR_SMLSERVER)/bin/smlserverc
	chmod a+x $(INSTDIR_SMLSERVER)/bin/smlserverc
	rm -f /usr/bin/smlserverc
	cp -f -p $(INSTDIR_SMLSERVER)/bin/smlserverc /usr/bin/smlserverc

SMLSERVER_HOST=hug.it.edu
SMLSERVER_HOSTDIR=$(SMLSERVER_HOST):/web/smlserver/www/dist

dist_smlserver:
	scp NEWS_SMLSERVER $(SMLSERVER_HOSTDIR)/NEWS_SMLSERVER-$(KITVERSION).txt
	scp README_SMLSERVER $(SMLSERVER_HOSTDIR)/README_SMLSERVER-$(KITVERSION).txt
	scp doc/smlserver.pdf $(SMLSERVER_HOSTDIR)/smlserver-$(KITVERSION).pdf
	scp ../smlserver-$(KITVERSION).tgz $(SMLSERVER_HOSTDIR)/
	scp $(RPMDIR)/RPMS/i386/smlserver-$(KITVERSION)-1.i386.rpm $(SMLSERVER_HOSTDIR)/
	scp $(RPMDIR)/SRPMS/smlserver-$(KITVERSION)-1.src.rpm $(SMLSERVER_HOSTDIR)/


MLKIT_HOST=ssh.itu.dk
MLKIT_HOSTDIR=$(MLKIT_HOST):/import/www/research/mlkit/dist
TESTDATE=2004-06-11

dist_mlkit:
	scp NEWS $(MLKIT_HOSTDIR)/NEWS-$(KITVERSION).txt
	scp README $(MLKIT_HOSTDIR)/README-$(KITVERSION).txt
	scp INSTALL $(MLKIT_HOSTDIR)/INSTALL-$(KITVERSION).txt
	scp doc/manual/mlkit.pdf $(MLKIT_HOSTDIR)/mlkit-$(KITVERSION).pdf
	scp ../test_reports/test_report-native-$(TESTDATE).dvi $(MLKIT_HOSTDIR)/test_report-native-$(KITVERSION).dvi
	scp ../test_reports/test_report-kam-$(TESTDATE).dvi $(MLKIT_HOSTDIR)/test_report-kam-$(KITVERSION).dvi
	scp ../mlkit-$(KITVERSION).tgz $(MLKIT_HOSTDIR)/
	scp $(RPMDIR)/RPMS/i386/mlkit-$(KITVERSION)-1.i386.rpm $(MLKIT_HOSTDIR)/
	scp $(RPMDIR)/SRPMS/mlkit-$(KITVERSION)-1.src.rpm $(MLKIT_HOSTDIR)/