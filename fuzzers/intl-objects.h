// Copyright 2013 the V8 project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


#ifndef V8_OBJECTS_INTL_OBJECTS_H_
#define V8_OBJECTS_INTL_OBJECTS_H_

//#include "v8/src/objects.h"
//#include "v8/src/unicode/uversion.h"
#include "unicode/smpdtfmt.h"

namespace U_ICU_NAMESPACE {
class BreakIterator;
class Collator;
class DecimalFormat;
class SimpleDateFormat;
}

#define DBLOG 0

template <typename T>
class Handle;

namespace fuzzer{

bool ExtractString(const char* &data, size_t &size, std::string &str);
std::string CanonicalizeLanguageTag(std::string locale_id);

std::string js_resolveLocale(std::string service, std::string locale);

class DateFormat {
 public:
  // Create a formatter for the specificied locale and options. Returns the
  // resolved settings for the locale / options.
  static icu::SimpleDateFormat* InitializeDateTimeFormat(const uint8_t* &data, const char *locale, size_t &size);

  // Layout description.

 private:
  DateFormat();
};

class NumberFormat {
 public:
  // Create a formatter for the specificied locale and options. Returns the
  // resolved settings for the locale / options.
  static icu::DecimalFormat* InitializeNumberFormat(const uint8_t* &data, const char *locale, size_t &size);

  // Layout description.

 private:
  NumberFormat();
};

class Collator {
 public:
  // Create a collator for the specificied locale and options. Returns the
  // resolved settings for the locale / options.
  static icu::Collator* InitializeCollator(const uint8_t* &data,
                                           const char *locale,
                                           size_t &size);

  // Layout description.

 private:
  Collator();
};

bool ExtractStringSetting(const uint8_t* &data, size_t &size,
                          const char* key, icu::UnicodeString* setting);
void print(const icu::UnicodeString& s, const char *name);
} //namespace fuzzer

#endif  // V8_OBJECTS_INTL_OBJECTS_H_
