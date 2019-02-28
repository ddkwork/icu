#!/bin/bash
# Copyright (c) 2014 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

# Remove entries currently not used in Chromium/V8.
function filter_locale_data {
  echo Removing unncessary categories in ${localedatapath}
  for langpath in ${localedatapath}/*.txt
  do
    echo Overwriting ${langpath} ...
    sed -r -i \
      '/^    characterLabel\{$/,/^    \}$/d
       /^    delimiters\{$/, /^    \}$/d
       /^    measurementSystemNames\{$/, /^    \}$/d
       /^    AuxExemplarCharacters\{.*\}$/d
       /^    AuxExemplarCharacters\{$/, /^    \}$/d
       /^    Ellipsis\{$/, /^    \}$/d
       /^    ExemplarCharacters\{.*\}$/d
       /^    ExemplarCharacters\{$/, /^    \}$/d
       /^    ExemplarCharactersNumbers\{.*\}$/d
       /^    ExemplarCharactersIndex\{.*\}$/d
       /^    ExemplarCharactersPunctuation\{.*\}$/d
       /^    ExemplarCharactersPunctuation\{$/, /^    \}$/d
       /^    Version\{.*\}$/d
       /^        (mon|tue|wed|thu|fri|sat|sun)(|-short|-narrow)\{$/, /^        \}$/d
       /^        (mon|tue|wed|thu|fri|sat|sun)(|-short|-narrow)\{.*\}$/d
       /^        (mon|tue|wed|thu|fri|sat|sun)-(short|narrow):alias\{.*\}$/d' ${langpath}
    # Delete empty blocks. Otherwise, locale fallback fails.
    # See crbug.com/v8/8414 .
    sed -r -i \
      '/^    fields\{$/ {
         N
         /^    fields\{\n    \}/ d
      }' "${langpath}"
  done
}

# Remove display names for languages that are not listed in the accept-language
# list of Chromium.
function filter_display_language_names {
  for lang in $(grep -v '^#' "${scriptdir}/accept_lang.list")
  do
    # Set $OP to '|' only if $ACCEPT_LANG_PATTERN is not empty.
    OP=${ACCEPT_LANG_PATTERN:+|}
    ACCEPT_LANG_PATTERN="${ACCEPT_LANG_PATTERN}${OP}${lang}"
  done
  ACCEPT_LANG_PATTERN="(${ACCEPT_LANG_PATTERN})[^a-z]"

  echo "Filtering out display names for non-A-L languages in ${langdatapath}"
  for langpath in ${langdatapath}/*.txt
  do
    target=${langpath}
    echo Overwriting ${target} ...
    sed -r -i \
    '/^    Keys\{$/,/^    \}$/d
     /^    Languages\{$/, /^    \}$/ {
       /^    Languages\{$/p
       /^        '${ACCEPT_LANG_PATTERN}'/p
       /^    \}$/p
       d
     }
     /^    Types\{$/,/^    \}$/d
     /^    Types%short\{$/,/^    \}$/d
     /^    characterLabelPattern\{$/,/^    \}$/d
     /^    Variants\{$/,/^    \}$/d' ${target}

    # Delete an empty "Languages" block. Otherwise, getting the display
    # name for all the language in a given locale (e.g. en_GB) would fail
    # when the above filtering sed command results in an empty "Languages"
    # block.
    sed -r -i \
    '/^    Languages\{$/ {
       N
       /^    Languages\{\n    \}/ d
    }' ${target}
  done
}


# Keep only the minimum locale data for non-UI languages.
function abridge_locale_data_for_non_ui_languages {
  for lang in $(grep -v '^#' "${scriptdir}/chrome_ui_languages.list")
  do
    # Set $OP to '|' only if $UI_LANGUAGES is not empty.
    OP=${UI_LANGUAGES:+|}
    UI_LANGUAGES="${UI_LANGUAGES}${OP}${lang}"
  done

  EXTRA_LANGUAGES=$(egrep -v -e '^#' -e "(${UI_LANGUAGES})" \
                    "${scriptdir}/accept_lang.list")

  echo Creating minimum locale data in ${localedatapath}
  for lang in ${EXTRA_LANGUAGES}
  do
    target=${localedatapath}/${lang}.txt
    [  -e ${target} ] || { echo "missing ${lang}"; continue; }
    echo Overwriting ${target} ...

    # Do not include '%%Parent' line on purpose.
    sed -n -r -i \
      '1, /^'${lang}'\{$/p
       /^    "%%ALIAS"\{/p
       /^    (LocaleScript|layout)\{$/, /^    \}$/p
       /^    Version\{.*$/p
       /^\}$/p' ${target}
  done

  echo Creating minimum locale data in ${langdatapath}
  for lang in ${EXTRA_LANGUAGES}
  do
    target=${langdatapath}/${lang}.txt
    [  -e ${target} ] || { echo "missing ${lang}"; continue; }
    echo Overwriting ${target} ...

    # Do not include '%%Parent' line on purpose.
    sed -n -r -i \
      '1, /^'${lang}'\{$/p
       /^    "%%ALIAS"\{/p
       /^    Languages\{$/, /^    \}$/ {
         /^    Languages\{$/p
         /^        '${lang}'\{.*\}$/p
         /^    \}$/p
       }
       /^\}$/p' ${target}
  done
}

# Keep only the currencies used by the larget 150 economies in terms of GDP.
# TODO(jshin): Use ucurr_isAvailable in ICU to drop more currencies.
# See also http://en.wikipedia.org/wiki/List_of_circulating_currencies
function filter_currency_data {
  unset KEEPLIST
  for currency in $(grep -v '^#' "${scriptdir}/currencies.list")
  do
    OP=${KEEPLIST:+|}
    KEEPLIST=${KEEPLIST}${OP}${currency}
  done
  KEEPLIST="(${KEEPLIST})"

  for i in ${dataroot}/curr/*.txt
  do
    locale=$(basename $i .txt)
    [ $locale == 'supplementalData' ] && continue;
    echo "Overwriting $i for $locale"
    sed -n -r -i \
      '1, /^'${locale}'\{$/ p
       /^    "%%ALIAS"\{/ p
       /^    ___\{..\}$/ p
       /^    %%Parent\{/ p
       /^    Currencies\{$/, /^    \}$/ {
         /^    Currencies\{$/ p
         /^        '$KEEPLIST'\{$/, /^        \}$/ p
         /^    \}$/ p
       }
       /^    Currencies%narrow\{$/, /^    \}$/ {
         /^    Currencies%narrow\{$/ p
         /^        '$KEEPLIST'\{".*\}$/ p
         /^    \}$/ p
       }
       /^    CurrencyPlurals\{$/, /^    \}$/ {
         /^    CurrencyPlurals\{$/ p
         /^        '$KEEPLIST'\{$/, /^        \}$/ p
         /^    \}$/ p
       }
       /^    [cC]urrency(Map|Meta|Spacing|UnitPatterns)\{$/, /^    \}$/ p
       /^    Version\{.*\}$/p
       /^\}$/p' "${i}"

    # Delete empty blocks. Otherwise, locale fallback fails.
    # See crbug.com/791318.
    sed -r -i \
      '/^    Currenc(ie.*|yPlurals)\{$/ {
         N
         /^    Currenc(ie.*|yPlurals)\{\n    \}/ d
      }' "${i}"
  done
}

# Remove the display names for numeric region codes other than
# 419 (Latin America) because we don't use them.
function filter_region_data {
  sed -i  '/[0-35-9][0-9][0-9]{/ d' ${dataroot}/region/*.txt
}

# big5han and gb2312han collation do not make any sense and nobody uses them.
function remove_legacy_chinese_codepoint_collation {
  echo "Removing Big5 / GB2312 / UniHan collation data from Chinese locale"
  target="${dataroot}/coll/zh.txt"
  echo "Overwriting ${target}"
  sed -r -i '/^        (uni|big5|gb2312)han\{$/,/^        \}$/ d' ${target}
}

#
# Only remove dname from unit.
function filter_dnam_in_unit_data {
  for i in ${dataroot}/unit/*.txt
  do
    echo Overwriting $i ...
    sed -r -i \
      '/^                dnam\{.*\}$/d' ${i}
  done
}

treeroot="$(dirname "$0")/.."
dataroot="${treeroot}/source/data"
scriptdir="${treeroot}/scripts"
localedatapath="${dataroot}/locales"
langdatapath="${dataroot}/lang"

filter_locale_data
filter_display_language_names
abridge_locale_data_for_non_ui_languages
filter_currency_data
filter_region_data
remove_legacy_chinese_codepoint_collation
filter_dnam_in_unit_data
