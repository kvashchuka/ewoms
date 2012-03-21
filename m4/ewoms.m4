dnl -*- autoconf -*-
# Macros needed to find eWoms and dependent libraries.  They are called by
# the macros in ${top_src_dir}/dependencies.m4, which is generated by
# "dunecontrol autogen"
AC_DEFUN([EWOMS_CHECKS],
[
  AC_CHECK_HEADER([valgrind/memcheck.h], 
                  [HAVE_VALGRIND_H="1"],
                  AC_MSG_WARN([valgrind/memcheck.h not found]))
  AS_IF([test "$HAVE_VALGRIND_H" = "1"],[
    AC_DEFINE(HAVE_VALGRIND, 1, [Define whether the valgrind header files for client requests are present.])
    ])
  if test "$HAVE_VALGRIND_H" == "1"; then
     DUNE_ADD_SUMMARY_ENTRY([Valgrind client requests],["yes"])
  else
     DUNE_ADD_SUMMARY_ENTRY([Valgrind client requests],["no"])
  fi

  AC_CHECK_HEADER([dune/istl/convergencecriteria.hh], 
                  [HAVE_ISTL_FIXPOINT_CRITERION="1"],
                  AC_MSG_WARN([dune/istl/convergencecriteria.hh not found]))
  AS_IF([test "$HAVE_ISTL_FIXPOINT_CRITERION" = "1"],[
    AC_DEFINE(HAVE_ISTL_FIXPOINT_CRITERION, 1, [Define whether ISTL provides pluggable convergence criteria.])
    ])
  if test "$HAVE_ISTL_FIXPOINT_CRITERION" == "1"; then
     DUNE_ADD_SUMMARY_ENTRY([ISTL patch for pluggable convergence criteria],["yes"])
  else
     DUNE_ADD_SUMMARY_ENTRY([ISTL patch for pluggable convergence criteria],["no"])
  fi

  # whether the compiler supports the auto keyword
  EWOMS_CHECK_AUTO
  if test "$HAVE_AUTO" != "yes"; then
      AC_MSG_ERROR([To use eWoms you need a compiler which supports the 'auto' keyword (e.g. GCC 4.5 or newer)])
  fi
  # check for the availablility of quadruple precision floating point
  # math and enable it if requested.
  EWOMS_CHECK_QUAD

  # Add the EWOMS_DEPRECATED* macros. TODO: remove after we depend on
  # a DUNE version which provides the DUNE_DEPRECATED_MSG macro!
  EWOMS_CHECK_DEPRECATED

  # Check whether the compiler supports __attribute__((always_inline))
  EWOMS_CHECK_ALWAYS_INLINE

  # Check whether the compiler supports __attribute__((unused))
  EWOMS_CHECK_UNUSED

  # check whether the constexpr keyword is present
  AC_REQUIRE([CONSTEXPR_CHECK])
  # define constexpr as const if it is not available. this is quite a HACK!
  if test "x$HAVE_CONSTEXPR" != "xyes"; then
      AC_DEFINE(constexpr, const, ['set 'constexpr' to 'const' if constexpr is not supported])
  fi

])

# checks only relevant for the eWoms module itself but not for modules
# which depend on it
AC_DEFUN([EWOMS_CHECKS_PRIVATE],
[
  if test "$enable_documentation" == "yes"; then
    AC_PROG_LATEX
    AC_PROG_BIBTEX
    AC_PROG_DVIPDF

    if test "$latex" != "no" && \
     test "$bibtex" != "no" && \
     test "$dvipdf" != "no"; then

     AC_LATEX_CLASS(scrreprt,have_latex_class_scrreprt)

     AC_LATEX_PACKAGE(amsfonts,scrreprt,have_latex_pkg_amsfonts)
     AC_LATEX_PACKAGE(amsmath,scrreprt,have_latex_pkg_amsmath)
     AC_LATEX_PACKAGE(amssymb,scrreprt,have_latex_pkg_amssymb)
     # AC_LATEX_PACKAGE(babel,scrreprt,have_latex_pkg_babel)
     AC_LATEX_PACKAGE(color,scrreprt,have_latex_pkg_color)
     AC_LATEX_PACKAGE(enumerate,scrreprt,have_latex_pkg_enumerate)
     AC_LATEX_PACKAGE(graphics,scrreprt,have_latex_pkg_graphics)
     AC_LATEX_PACKAGE(graphicx,scrreprt,have_latex_pkg_graphicx)
     AC_LATEX_PACKAGE(hyperref,scrreprt,have_latex_pkg_hyperref)
     AC_LATEX_PACKAGE(hyphenat,scrreprt,have_latex_pkg_hyphenat)
     AC_LATEX_PACKAGE(inputenc,scrreprt,have_latex_pkg_inputenc)
     AC_LATEX_PACKAGE(layout,scrreprt,have_latex_pkg_layout)
     AC_LATEX_PACKAGE(listings,scrreprt,have_latex_pkg_listings)
     AC_LATEX_PACKAGE(lscape,scrreprt,have_latex_pkg_lscape)
     AC_LATEX_PACKAGE(makeidx,scrreprt,have_latex_pkg_makeidx)
     AC_LATEX_PACKAGE(pstricks,scrreprt,have_latex_pkg_pstricks)
     AC_LATEX_PACKAGE(rotating,scrreprt,have_latex_pkg_rotating)
     AC_LATEX_PACKAGE(scrpage2,scrreprt,have_latex_pkg_scrpage2)
     AC_LATEX_PACKAGE(subfig,scrreprt,have_latex_pkg_subfig)
     AC_LATEX_PACKAGE(theorem,scrreprt,have_latex_pkg_theorem)
     AC_LATEX_PACKAGE(tabularx,scrreprt,have_latex_pkg_tabularx)
     AC_LATEX_PACKAGE(ulem,scrreprt,have_latex_pkg_ulem)
     AC_LATEX_PACKAGE(units,scrreprt,have_latex_pkg_units)
     AC_LATEX_PACKAGE(xspace,scrreprt,have_latex_pkg_xspace)
    fi
  fi

  # only build the handbook if the documentation is build, latex is
  # available and the tree is checked out via a version control system
  build_handbook=yes
  if test "$enable_documentation" != "yes"; then
     build_handbook="no"
     summary_message="Configure parameter --enable-documentation not specified"
  elif test "$CONVERT" == "no" || test "$CONVERT" == "" ; then
    build_handbook="no"
    summary_message="Command 'convert' not found"
  elif test "$latex" == "no" || test "$latex" == ""; then
    summary_message="Command 'latex' not found"
    build_handbook="no"
  elif test "$bibtex" == "no" || test "$bibtex" == ""; then
    summary_message="Command 'bibtex' not found"
    build_handbook="no"
  elif test "$dvipdf" == "no" || test "$dvipdf" == "" ; then
    summary_message="Command 'dvipdf' not found"
    build_handbook="no"
  elif test "$have_latex_class_scrreprt" != "yes"; then
    summary_message="Latex class 'scrreprt' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_amsfonts" != "yes"; then
    summary_message="Latex package 'amsfonts' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_amsmath" != "yes"; then
    summary_message="Latex package 'amsmath' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_amssymb" != "yes"; then
    summary_message="Latex package 'amssymb' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_color" != "yes"; then
    summary_message="Latex package 'color' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_enumerate" != "yes"; then
    summary_message="Latex package 'enumerate' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_graphics" != "yes"; then
    summary_message="Latex package 'graphics' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_graphicx" != "yes"; then
    summary_message="Latex package 'graphicx' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_hyperref" != "yes"; then
    summary_message="Latex package 'hyperref' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_hyphenat" != "yes"; then
    summary_message="Latex package 'hyphenat' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_inputenc" != "yes"; then
    summary_message="Latex package 'inputenc' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_layout" != "yes"; then
    summary_message="Latex package 'layout' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_listings" != "yes"; then
    summary_message="Latex package 'listings' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_lscape" != "yes"; then
    summary_message="Latex package 'lscape' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_makeidx" != "yes"; then
    summary_message="Latex package 'makeidx' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_pstricks" != "yes"; then
    summary_message="Latex package 'pstricks' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_rotating" != "yes"; then
    summary_message="Latex package 'rotating' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_scrpage2" != "yes"; then
    summary_message="Latex package 'scrpage2' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_subfig" != "yes"; then
    summary_message="Latex package 'subfig' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_theorem" != "yes"; then
    summary_message="Latex package 'theorem' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_tabularx" != "yes"; then
    summary_message="Latex package 'tabularx' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_ulem" != "yes"; then
    summary_message="Latex package 'ulem' not available"
    build_handbook="no"
  elif test "$have_latex_pkg_units" != "yes"; then
    summary_message="Latex package 'units' not available"
    build_handbook="no"
  fi

  AC_SUBST([LATEX],[$latex])
  AC_SUBST([BIBTEX],[$bibtex])
  AC_SUBST([DVIPDF],[$dvipdf])

  AM_CONDITIONAL([BUILD_HANDBOOK], [test "$build_handbook" == "yes"])
  if test "$build_handbook" == "yes"; then
     DUNE_ADD_SUMMARY_ENTRY([Build eWoms handbook],[$build_handbook])
  else
     DUNE_ADD_SUMMARY_ENTRY([Build eWoms handbook],[$build_handbook ($summary_message)])
  fi
])

# EWOMS_CHECK_MODULES(NAME, HEADER, SYMBOL)
#
# THIS MACRO IS JUST A COPY OF DUNE_CHECK_MODULES WITH THE REQUIREMENT THAT ALL
# HEADERS MUST RESIDE IN $MODULE_ROOT/dune REMOVED. REMOVE THIS MACRO AS SOON AS DUNE
# DOES NOT FEATURE THIS BUG ANYMORE.
#
# Generic check for dune modules.  This macro should not be used directly, but
# in the modules m4/{module}.m4 in the {MODULE}_CHECK_MODULE macro.  The
# {MODULE}_CHECK_MODULE macro knows the parameters to call this
# DUNE_CHECK_MODULES macro with, and it does not take any parameters itself,
# so it may be used with AC_REQUIRE.
#
# NAME   Name of the module, lowercase with dashes (like "dune-common").  The
#        value must be known when autoconf runs, so shell variables in the
#        value are not permissible.
#
# HEADER Header to check for.  The check will really be for <dune/{HEADER}>,
#        so the header must reside within a directory called "dune".
#
# SYMBOL Symbol to check for in the module's library.  If this argument is
#        empty or missing, it is assumed that the module does not provide a
#        library.  The value must be known when autoconf runs, so shell
#        variables in the value are not permissible.  This value is actually
#        handed to AC_TRY_LINK unchanged as the FUNCTION-BODY argument, so it
#        may contain more complex stuff than a simple symbol.
#
#        The name of the library is assumed to be the same as the module name,
#        with any occurance of "-" removed.  The path of the library is
#        obtained from pkgconfig for installed modules, or assumed to be the
#        directory "lib" within the modules root for non-installed modules.
#
# In the following, {module} is {NAME} with any "-" replaced by "_" and
# {MODULE} is the uppercase version of {module}.
#
# configure options:
#   --with-{NAME}
#
# configure/shell variables:
#   {MODULE}_ROOT, {MODULE}_LIBDIR
#   HAVE_{MODULE} (1 or 0)
#   with_{module} ("yes" or "no")
#   DUNE_CPPFLAGS, DUNE_LDFLAGS, DUNE_LIBS (adds the modules values here,
#         substitution done by DUNE_CHECK_ALL)
#   ALL_PKG_CPPFLAGS, ALL_PKG_LDFLAGS, ALL_PKG_LIBS (adds the modules values
#         here, substitution done by DUNE_CHECK_ALL)
#   DUNE_PKG_CPPFLAGS, DUNE_PKG_LDFLAGS, DUNE_PKG_LIBS (deprecated, adds the
#         modules values here)
#   {MODULE}_VERSION
#   {MODULE}_VERSION_MAJOR
#   {MODULE}_VERSION_MINOR
#   {MODULE}_VERSION_REVISION
#
# configure substitutions/makefile variables:
#   {MODULE}_CPPFLAGS, {MODULE}_LDFLAGS, {MODULE}_LIBS
#   {MODULE}_ROOT
#   {MODULE}_LIBDIR (only if modules provides a library)
#
# preprocessor defines:
#   HAVE_{MODULE} (1 or undefined)
#   {MODULE}_VERSION
#   {MODULE}_VERSION_MAJOR
#   {MODULE}_VERSION_MINOR
#   {MODULE}_VERSION_REVISION
#
# automake conditionals:
#   HAVE_{MODULE}
AC_DEFUN([EWOMS_CHECK_MODULES],[
  AC_REQUIRE([AC_PROG_CXX])
  AC_REQUIRE([AC_PROG_CXXCPP])
  AC_REQUIRE([PKG_PROG_PKG_CONFIG])
  AC_REQUIRE([DUNE_DISABLE_LIBCHECK])
  AC_REQUIRE([LT_OUTPUT])

  # ____DUNE_CHECK_MODULES_____ ($1)

  m4_pushdef([_dune_name], [$1])
  m4_pushdef([_dune_module], [m4_translit(_dune_name, [-], [_])])
  m4_pushdef([_dune_header], [$2])
  m4_pushdef([_dune_ldpath], [lib])
  m4_pushdef([_dune_lib],    [m4_translit(_dune_name, [-], [])])
  m4_pushdef([_dune_symbol], [$3])
  m4_pushdef([_DUNE_MODULE], [m4_toupper(_dune_module)])

  # switch tests to c++
  AC_LANG_PUSH([C++])

  # the usual option...
  AC_ARG_WITH(_dune_name,
    AS_HELP_STRING([--with-_dune_name=PATH],[_dune_module directory]))

  # backup of flags
  ac_save_CPPFLAGS="$CPPFLAGS"
  ac_save_LIBS="$LIBS"
  ac_save_LDFLAGS="$LDFLAGS"
  CPPFLAGS=""
  LIBS=""

  ##
  ## Where is the module $1?
  ##

  AC_MSG_CHECKING([for $1 installation or source tree])

  # is a directory set?
  AS_IF([test -z "$with_[]_dune_module"],[
    #
    # search module $1 via pkg-config
    #
    with_[]_dune_module="global installation"
    AS_IF([test -z "$PKG_CONFIG"],[
      AC_MSG_RESULT([failed])
      AC_MSG_NOTICE([could not search for module _dune_name])
      AC_MSG_ERROR([pkg-config is required for using installed modules])
    ])
    AS_IF(AC_RUN_LOG([$PKG_CONFIG --exists --print-errors "$1"]),[
      _dune_cm_CPPFLAGS="`$PKG_CONFIG --cflags _dune_name`" 2>/dev/null
      _DUNE_MODULE[]_ROOT="`$PKG_CONFIG --variable=prefix _dune_name`" 2>/dev/null 
      _DUNE_MODULE[]_VERSION="`$PKG_CONFIG --modversion _dune_name`" 2>/dev/null
      _dune_cm_LDFLAGS=""
      ifelse(_dune_symbol,,
        [_DUNE_MODULE[]_LIBDIR=""
         _dune_cm_LIBS=""],
        [_DUNE_MODULE[]_LIBDIR=`$PKG_CONFIG --variable=libdir _dune_name 2>/dev/null`
         _dune_cm_LIBS="-L$_DUNE_MODULE[]_LIBDIR -l[]_dune_lib"])
      HAVE_[]_DUNE_MODULE=1
      AC_MSG_RESULT([global installation in $_DUNE_MODULE[]_ROOT])
    ],[
      HAVE_[]_DUNE_MODULE=0
      AC_MSG_RESULT([not found])
    ])
  ],[
    #
    # path for module $1 is specified via command line
    #
    AS_IF([test -d "$with_[]_dune_module"],[
      # expand tilde / other stuff
      _DUNE_MODULE[]_ROOT=`cd $with_[]_dune_module && pwd`

      # expand search path (otherwise empty CPPFLAGS)
      AS_IF([test -d "$_DUNE_MODULE[]_ROOT/include/dune"],[
        # Dune was installed into directory given by with-dunecommon
        _dune_cm_CPPFLAGS="-I$_DUNE_MODULE[]_ROOT/include"
        _DUNE_MODULE[]_BUILDDIR=_DUNE_MODULE[]_ROOT
        _DUNE_MODULE[]_VERSION="`PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$_DUNE_MODULE[]_ROOT/lib/pkgconfig $PKG_CONFIG --modversion _dune_name`" 2>/dev/null
      ],[
        _DUNE_MODULE[]_SRCDIR=$_DUNE_MODULE[]_ROOT
        # extract src and build path from Makefile, if found
	    AS_IF([test -f $_DUNE_MODULE[]_ROOT/Makefile],[
          _DUNE_MODULE[]_SRCDIR="`sed -ne '/^abs_top_srcdir = /{s/^abs_top_srcdir = //; p;}' $_DUNE_MODULE[]_ROOT/Makefile`"
		])
        _dune_cm_CPPFLAGS="-I$_DUNE_MODULE[]_SRCDIR"
        _DUNE_MODULE[]_VERSION="`grep Version $_DUNE_MODULE[]_SRCDIR/dune.module | sed -e 's/^Version: *//'`" 2>/dev/null
      ])
      _dune_cm_LDFLAGS=""
      ifelse(_dune_symbol,,
        [_DUNE_MODULE[]_LIBDIR=""
         _dune_cm_LIBS=""],
        [_DUNE_MODULE[]_LIBDIR="$_DUNE_MODULE[]_ROOT/lib"
         _dune_cm_LIBS="-L$_DUNE_MODULE[]_LIBDIR -l[]_dune_lib"])
      # set expanded module path
      with_[]_dune_module="$_DUNE_MODULE[]_ROOT"
      HAVE_[]_DUNE_MODULE=1
      AC_MSG_RESULT([found in $_DUNE_MODULE[]_ROOT])
    ],[
      HAVE_[]_DUNE_MODULE=0
      AC_MSG_RESULT([not found])
      AC_MSG_ERROR([_dune_name-directory $with_[]_dune_module does not exist])
    ])
  ])

  CPPFLAGS="$ac_save_CPPFLAGS $DUNE_CPPFLAGS $_dune_cm_CPPFLAGS"
  ##  
  ## check for an arbitrary header
  ##
  AC_CHECK_HEADER([dune/[]_dune_header],
    [HAVE_[]_DUNE_MODULE=1; DUNE_[]_HEADER_PREFIX="dune/"],
    [HAVE_[]_DUNE_MODULE=0])

  AS_IF([test "$HAVE_[]_DUNE_MODULE" != "1"],[
    AC_CHECK_HEADER([[]_dune_header],
      [HAVE_[]_DUNE_MODULE=1; DUNE_[]_HEADER_PREFIX=""],
      [HAVE_[]_DUNE_MODULE=0])
  ])    

  AS_IF([test "$HAVE_[]_DUNE_MODULE" != "1"],[
    AC_MSG_WARN([$_DUNE_MODULE[]_ROOT does not seem to contain a valid _dune_name (dune/[]_dune_header not found)])
  ])
  
  ##
  ## check for lib (if lib name was provided)
  ##
  ifelse(_dune_symbol,,
    AC_MSG_NOTICE([_dune_name does not provide libs]),

    AS_IF([test "x$enable_dunelibcheck" = "xno"],[
      AC_MSG_WARN([library check for _dune_name is disabled. DANGEROUS!])
    ],[
      AS_IF([test "x$HAVE_[]_DUNE_MODULE" = "x1"],[

        # save current LDFLAGS
        ac_save_CXX="$CXX"
        HAVE_[]_DUNE_MODULE=0

        # define LTCXXLINK like it will be defined in the Makefile
        CXX="./libtool --tag=CXX --mode=link $ac_save_CXX"

        # use module LDFLAGS
        LDFLAGS="$ac_save_LDFLAGS $DUNE_LDFLAGS $DUNE_PKG_LDFLAGS $_dune_cm_LDFLAGS"
        LIBS="$_dune_cm_LIBS $DUNE_LIBS $LIBS"

        AC_MSG_CHECKING([for lib[]_dune_lib])

        AC_TRY_LINK(dnl
          [#]include<$DUNE_[]_HEADER_PREFIX/[]_dune_header>,
          _dune_symbol,
          [
            AC_MSG_RESULT([yes])
            HAVE_[]_DUNE_MODULE=1
          ],[
            AC_MSG_RESULT([no])
            HAVE_[]_DUNE_MODULE=0
            AS_IF([test -n "$_DUNE_MODULE[]_ROOT"],[
             AC_MSG_WARN([$with_[]_dune_module does not seem to contain a valid _dune_name (failed to link with lib[]_dune_lib[].la)])
            ])
          ]
        )
      ])

      # reset variables
      CXX="$ac_save_CXX"
    ])
  )

  # did we succeed?
  AS_IF([test "x$HAVE_[]_DUNE_MODULE" = "x1"],[
    # add the module's own flags and libs to the modules and the global
    # variables
    DUNE_ADD_MODULE_DEPS(m4_defn([_dune_name]), m4_defn([_dune_name]),
        [$_dune_cm_CPPFLAGS], [$_dune_cm_LDFLAGS], [$_dune_cm_LIBS])

    # set variables for our modules
    AC_SUBST(_DUNE_MODULE[]_CPPFLAGS, "$_DUNE_MODULE[]_CPPFLAGS")
    AC_SUBST(_DUNE_MODULE[]_LDFLAGS, "$_DUNE_MODULE[]_LDFLAGS")
    AC_SUBST(_DUNE_MODULE[]_LIBS, "$_DUNE_MODULE[]_LIBS")
    AC_SUBST(_DUNE_MODULE[]_ROOT, "$_DUNE_MODULE[]_ROOT")
    ifelse(m4_defn([_dune_symbol]),,
      [],
      [AC_SUBST(_DUNE_MODULE[]_LIBDIR)
    ])
    AC_DEFINE(HAVE_[]_DUNE_MODULE, 1, [Define to 1 if] _dune_name [was found])

    DUNE_PARSE_MODULE_VERSION(_dune_name, $_DUNE_MODULE[]_VERSION)

    # set DUNE_* variables
    # This should actually be unneccesary, but I'm keeping it in here for now
    # for backward compatibility
    DUNE_LDFLAGS="$DUNE_LDFLAGS $_DUNE_MODULE[]_LDFLAGS"
    DUNE_LIBS="$_DUNE_MODULE[]_LIBS $DUNE_LIBS"
    
    # add to global list
    # only add my flags other flags are added by other packages 
    DUNE_PKG_CPPFLAGS="$DUNE_PKG_CPPFLAGS $_DUNE_MODULE[]_CPPFLAGS"
    DUNE_PKG_LIBS="$DUNE_PKG_LIBS $LIBS"
    DUNE_PKG_LDFLAGS="$DUNE_PKG_LDFLAGS $_DUNE_MODULE[]_LDFLAGS"

    with_[]_dune_module="yes"
  ],[
    with_[]_dune_module="no"
  ])

  AM_CONDITIONAL(HAVE_[]_DUNE_MODULE, test x$HAVE_[]_DUNE_MODULE = x1)

  # reset previous flags
  CPPFLAGS="$ac_save_CPPFLAGS"
  LDFLAGS="$ac_save_LDFLAGS"
  LIBS="$ac_save_LIBS"

  # add this module to DUNE_SUMMARY
  DUNE_MODULE_ADD_SUMMARY_ENTRY(_dune_name)

  # remove local variables
  m4_popdef([_dune_name])
  m4_popdef([_dune_module])
  m4_popdef([_dune_header])
  m4_popdef([_dune_ldpath])
  m4_popdef([_dune_lib])
  m4_popdef([_dune_symbol])
  m4_popdef([_DUNE_MODULE])

  # restore previous language settings (leave C++)
  AC_LANG_POP([C++])
])

# Additional checks needed to find eWoms
# This macro should be invoked by every module which depends on dumux, but
# not by dumux itself
AC_DEFUN([EWOMS_CHECK_MODULE],
[
  EWOMS_CHECK_MODULES([ewoms],[dumux/common/exceptions.hh])
])
