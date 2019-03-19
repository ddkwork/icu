# © 2016 and later: Unicode, Inc. and others.
# License & terms of use: http://www.unicode.org/copyright.html#License
ZONE_CLDR_VERSION = %version%
# A list of txt's to build
# The downstream packager may not need this file at all if their package is not
# constrained by
# the size (and/or their target OS already has ICU with the full locale data.)
#
# Listed below are locale data files necessary for 40 + 1 + 8 languages Chrome
# is localized to.
#
# In addition to them, 40+ "abridged" locale data files are listed. Chrome is
# localized to them, but
# uses a few categories of data in those locales for IDN handling and language
# name listing (in the UI).
# Aliases which do not have a corresponding xx.xml file (see icu-config.xml &
# build.xml)
ZONE_SYNTHETIC_ALIAS =

# All aliases (to not be included under 'installed'), but not including root.
ZONE_ALIAS_SOURCE = $(ZONE_SYNTHETIC_ALIAS)\
 zh_CN.txt zh_TW.txt zh_HK.txt zh_SG.txt\
 no.txt in.txt iw.txt

# Ordinary resources
ZONE_SOURCE =\
 am.txt\
 ar.txt\
 bg.txt\
 bn.txt\
 ca.txt\
 cs.txt\
 da.txt\
 de.txt\
 el.txt\
 en.txt en_001.txt en_150.txt\
 en_AU.txt en_CA.txt en_GB.txt en_IN.txt en_NZ.txt en_ZA.txt\
 es.txt es_419.txt es_MX.txt es_AR.txt es_US.txt\
 et.txt\
 fa.txt\
 fi.txt\
 fil.txt\
 fr.txt fr_CA.txt\
 he.txt\
 hi.txt\
 hr.txt\
 hu.txt\
 id.txt\
 it.txt\
 ja.txt\
 ko.txt\
 lt.txt\
 lv.txt\
 nb.txt\
 nl.txt\
 pl.txt\
 pt.txt pt_PT.txt\
 ro.txt\
 ru.txt\
 sk.txt\
 sl.txt\
 sr.txt\
 sv.txt\
 sw.txt\
 th.txt\
 tr.txt\
 uk.txt\
 vi.txt\
 zh.txt zh_Hans.txt zh_Hans_CN.txt zh_Hans_SG.txt\
 zh_Hant.txt zh_Hant_TW.txt zh_Hant_HK.txt
