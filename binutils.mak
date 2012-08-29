BINUTILS_VERSION    := 2.22
BINUTILS_SOURCE     := $(TOOLCHAIN_SRCDIR)/binutils-$(BINUTILS_VERSION).tar.bz2
BINUTILS_DOWNLOAD   := http://ftp.gnu.org/gnu/binutils/binutils-$(BINUTILS_VERSION).tar.bz2
BINUTILS_PATCHES    := 

# Download
$(BINUTILS_SOURCE):
	$(call target_mkdir)
	$(call cmd_msg,WGET,$(subst $(SRC)/,,$(@)))
	$(Q)wget -c -O $(@).part $(BINUTILS_DOWNLOAD)
	$(Q)mv $(@).part $(@)


# Extract
$(TOOLCHAIN_BUILDDIR)/.binutils-extract: $(BINUTILS_SOURCE)
	$(Q)mkdir -p $(TOOLCHAIN_BUILDDIR)
	$(call cmd_msg,EXTRACT,$(subst $(SRC)/$(SRCSUBDIR)/,,$(BINUTILS_SOURCE)))
	$(Q)tar -C $(TOOLCHAIN_BUILDDIR) -xjf $(BINUTILS_SOURCE)
	$(call cmd_msg,PATCH,$(subst $(SRC)/$(SRCSUBDIR)/,,$(BINUTILS_PATCHES)))
	$(Q)$(foreach patch,$(BINUTILS_PATCHES), \
		cd $(TOOLCHAIN_BUILDDIR)/binutils-$(BINUTILS_VERSION); \
		patch -Np1 -i $(patch) $(QOUTPUT); \
	)
	$(Q)touch $(@)


# Configure
$(TOOLCHAIN_BUILDDIR)/.binutils-configure: $(TOOLCHAIN_BUILDDIR)/.binutils-extract
	$(Q)if [ -d "$(TOOLCHAIN_BUILDDIR)/binutils-build" ]; then \
		rm -rf $(TOOLCHAIN_BUILDDIR)/binutils-build; \
	fi
	$(Q)mkdir -p $(TOOLCHAIN_BUILDDIR)/binutils-build
	$(call cmd_msg,CONFIG,binutils-$(BINUTILS_VERSION) ($(TOOLCHAIN_TARGET)))
	$(Q)cd $(TOOLCHAIN_BUILDDIR)/binutils-build; \
		../binutils-$(BINUTILS_VERSION)/configure \
		--disable-werror \
		--enable-multilib \
		--with-gnu-as \
		--with-gnu-ld \
		--disable-nls \
		--prefix=$(TOOLCHAIN_ROOTDIR) \
		--target=$(TOOLCHAIN_TARGET) \
		$(QOUTPUT)
	$(Q)touch $(@)


# Compile
$(TOOLCHAIN_BUILDDIR)/.binutils-compile: $(TOOLCHAIN_BUILDDIR)/.binutils-configure
	$(call cmd_msg,COMPILE,binutils-$(BINUTILS_VERSION) ($(TOOLCHAIN_TARGET)))
	$(Q)cd $(TOOLCHAIN_BUILDDIR)/binutils-build; $(MAKE) $(SUBMAKEFLAGS) $(MAKEFLAGS) all $(QOUTPUT)
	$(Q)touch $(@)


# Install
$(TOOLCHAIN_BUILDDIR)/.binutils-install: $(TOOLCHAIN_BUILDDIR)/.binutils-compile
	$(call cmd_msg,INSTALL,binutils-$(BINUTILS_VERSION) ($(TOOLCHAIN_TARGET)))
	$(Q)cd $(TOOLCHAIN_BUILDDIR)/binutils-build; $(MAKE) $(MAKEFLAGS) install $(QOUTPUT)
	$(Q)touch $(@)


# Download, build and install binutils to run on the host system.
BINUTILS_TARGET := $(TOOLCHAIN_BUILDDIR)/.binutils-install
all-binutils: $(BINUTILS_TARGET)
.PHONY: all-binutils

all: $(BINUTILS_TARGET)
download: $(BINUTILS_SOURCE)
