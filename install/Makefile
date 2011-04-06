# Copyright (c) 2011, Jan Vlcek
# All rights reserved.
#
# For further information see enclosed LICENSE file
#
# Author: Jan Vlcek <xvlcek03@stud.fit.vutbr.cz>

# A phony target is one that is not really the name of a file.
# It is just a name for some commands to be executed when you
# make an explicit request. There are two reasons to use a
# phony target: to avoid a conflict with a file of the same
# name, and to improve performance.
.PHONY: build

# Settings for tests
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin
SERVER_HOST=localhost

# Directory where is the Cobertura
COBERTURA_DIR=cobertura-1.9.4.1

# Path to the main Spacewalk application jar which will be instrumented
RHN_JAR_PATH=/usr/share/rhn/lib/rhn.jar

# Directories where will be stored the temporary files used during instrumentation
RHN_JAR_CLASSES_DIRNAME=rhn_jar_classes
RHN_JAR_INSTR_DIRNAME=rhn_jar_instr
RHN_JAR_FINAL_DIRNAME=rhn_jar_final

# Name of the jar file after successful instrumentation
RHN_JAR_INSTR=rhn.cobertura.jar

# Name of the original jar file
RHN_JAR_ORIGINAL=rhn.original.jar

# Path to the Tomcat server service
TOMCAT_SERVICE=/etc/init.d/tomcat6


build: unjar instrument merge jar replace restart-tomcat

# Unpacks the rhn.jar
# 
# NOTE: If original rhn.jar is symlink, it is considered already instrumented. The local
#       original rhn.jar will be used instead
unjar:
	test -L $(RHN_JAR_PATH) || cp $(RHN_JAR_PATH) $(RHN_JAR_ORIGINAL)
	rm -rf $(RHN_JAR_CLASSES_DIRNAME)
	mkdir $(RHN_JAR_CLASSES_DIRNAME)
	cd $(RHN_JAR_CLASSES_DIRNAME) && jar xf ../$(RHN_JAR_ORIGINAL)

# Instruments the classes of unpacked rhn.jar
# 
# NOTE: If there is no cobertura's output and instrumentation executes successfully,
#       the rhn.jar has been probably instrumented before
instrument:
	rm -rf $(RHN_JAR_INSTR_DIRNAME)
	mkdir $(RHN_JAR_INSTR_DIRNAME)
	chmod a+x $(COBERTURA_DIR)/cobertura-instrument.sh
	java net.sourceforge.cobertura.instrument.Main --destination $(RHN_JAR_INSTR_DIRNAME) $(RHN_JAR_CLASSES_DIRNAME)

# Merges the original classes and content of rhn.jar with the instrumented classes
# 
# NOTE: Slash preceding the last copy disables the default options and therefore allows 
#       overwriting without asking
merge:
	rm -rf $(RHN_JAR_FINAL_DIRNAME)
	mkdir $(RHN_JAR_FINAL_DIRNAME)
	cp -r $(RHN_JAR_CLASSES_DIRNAME)/* $(RHN_JAR_FINAL_DIRNAME)
	\cp -r $(RHN_JAR_INSTR_DIRNAME)/* $(RHN_JAR_FINAL_DIRNAME)

# Packs the successfully instrumented rhn.jar classes into new jar file
jar:
	jar cf $(RHN_JAR_INSTR) -C $(RHN_JAR_FINAL_DIRNAME) .

# Replaces the original rhn.jar with the instrumented one
replace: $(RHN_JAR_ORIGINAL) $(RHN_JAR_INSTR)
	rm -f $(RHN_JAR_PATH)
	ln -s $(RHN_JAR_INSTR) $(RHN_JAR_PATH)

# Restarts the tomcat server
restart-tomcat:
	$(TOMCAT_SERVICE) restart

# Rollbacks the installation by switching back to original rhn.jar
rollback: $(RHN_JAR_ORIGINAL)
	rm -f $(RHN_JAR_PATH)
	cp $(RHN_JAR_ORIGINAL) $(RHN_JAR_PATH)

# NOTE: Does not remove the original rhn.jar file because of possible later rollback
clean:
	rm -f *~ $(RHN_JAR_INSTR)
	rm -rf $(RHN_JAR_CLASSES_DIRNAME) $(RHN_JAR_INSTR_DIRNAME) $(RHN_JAR_FINAL_DIRNAME)

