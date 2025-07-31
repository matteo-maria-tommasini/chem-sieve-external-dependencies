/*
Copyright (C) 2011,2012 Remik Ziemlinski. See MIT-LICENSE.

CHANGELOG

v0.0.0 20110502 rsz Created.
V1.0.0 20110522 rsz Extended to show eta with growing bar.
v2.0.0 20110525 rsz Added time elapsed.
v2.0.1 20111006 rsz Added default constructor value.
v2.0.1 20250731 mmt Changed sprintf to snprintf to silence compilation warnings
*/

/**
 * @file ezETAProgressBar.h
 * @brief One-line refreshing progress bar with ETA display.
 *
 * This class implements a progress bar that can be used to display the
 * progress of a task in the console, inspired by tools like wget.
 * The progress bar visually represents the percentage completed,
 * and estimates the time remaining (ETA) until completion.
 *
 * The progress bar is capable of updating its display dynamically as
 * progress is made, showing the current status of the task in a
 * single line.
 */

#ifndef EZ_ETAPROGRESSBAR_H
#define EZ_ETAPROGRESSBAR_H

#include <assert.h>
#include <stdio.h>
#include <string.h>

#include <iostream>
#include <string>

#ifdef WIN32
#include <windows.h>
#else
#include <sys/ioctl.h>
#include <sys/time.h>
#endif

namespace ez {
// One-line refreshing progress bar inspired by wget that shows ETA (time
// remaining). 90% [##################################################     ] ETA
// 12d 23h 56s
class ezETAProgressBar {
 public:
  /**
   * @brief Constructs a progress bar with an optional total count.
   * @param _n Total number of steps for the progress bar (default is 0).
   */
  ezETAProgressBar(unsigned int _n = 0) : n(_n), pct(0), cur(0), width(80) {}

  /** @brief Resets the progress bar to its initial state. */
  void reset() {
    pct = 0;
    cur = 0;
  }

  /** @brief Starts the progress bar timer. */
  void start() {
#ifdef WIN32
    assert(QueryPerformanceFrequency(&g_llFrequency) != 0);
#endif
    startTime = osQueryPerfomance();
    setPct(0);
  }

  /** @brief Increments the progress by one step. */
  void operator++() {
    if (cur >= n) return;
    ++cur;

    setPct(((float)cur) / n);
  };
  /**
   * @brief Returns the current time in microseconds since the epoch.
   * @return Current time in microseconds.
   */
  // http://stackoverflow.com/questions/3283804/c-get-milliseconds-since-some-date
  long long osQueryPerfomance() {
#ifdef WIN32
    LARGE_INTEGER llPerf = {0};
    QueryPerformanceCounter(&llPerf);
    return llPerf.QuadPart * 1000ll / (g_llFrequency.QuadPart / 1000ll);
#else
    struct timeval stTimeVal;
    gettimeofday(&stTimeVal, NULL);
    return stTimeVal.tv_sec * 1000000ll + stTimeVal.tv_usec;
#endif
  }

  /**
   * @brief Converts seconds into a human-readable string format.
   * @param t Time in seconds.
   * @return Formatted time string.
   */
  std::string secondsToString(long long t) {
    int days = t / 86400;
    long long sec = t - days * 86400;
    int hours = sec / 3600;
    sec -= hours * 3600;
    int mins = sec / 60;
    sec -= mins * 60;
    char tmp[8];
    std::string out;

    if (days) {
      //sprintf(tmp, "%dd ", days);
      snprintf(tmp, sizeof(tmp), "%dd ", days);
      out += tmp;
    }

    if (hours >= 1) {
      //sprintf(tmp, "%dh ", hours);
      snprintf(tmp, sizeof(tmp), "%dd ", days);
      out += tmp;
    }

    if (mins >= 1) {
      //sprintf(tmp, "%dm ", mins);
      snprintf(tmp, sizeof(tmp), "%dd ", days);
      out += tmp;
    }

    if (sec >= 1) {
      //sprintf(tmp, "%ds", (int)sec);
      snprintf(tmp, sizeof(tmp), "%dd ", days);
      out += tmp;
    }

    if (out.empty()) out = "0s";

    return out;
  }

  /**
   * @brief Sets the progress percentage.
   * @param Pct Progress percentage as a float (0.0 to 1.0).
   */
  // Set 0.0-1.0, where 1.0 equals 100%.
  void setPct(float Pct) {
    endTime = osQueryPerfomance();
    char pctstr[5];
    //sprintf(pctstr, "%3d%%", (int)(100 * Pct));
    snprintf(pctstr, sizeof(pctstr), "%3d%%", (int)(100 * Pct));
    // Compute how many tics we can display.
    int nticsMax = (width - 27);
    int ntics = (int)(nticsMax * Pct);
    std::string out(pctstr);
    out.append(" [");
    out.append(ntics, '+');
    out.append(nticsMax - ntics, ' ');
    out.append("] ");
    out.append((Pct < 1.0) ? "ETA " : "in ");
    // Seconds.
    long long dt = (long long)((endTime - startTime) / 1000000.0);
    std::string tstr;
    if (Pct >= 1.0) {
      // Print overall time and newline.
      tstr = secondsToString(dt);
      out.append(tstr);
      if (out.size() < width) out.append(width - out.size(), ' ');

      out.append("\n");
      std::cout << out;
      return;
    } else {
      float eta = 999999.;
      if (Pct > 0.0) eta = dt * (1.0 - Pct) / Pct;

      if (eta > 604800.0)
        out.append("> 1 week");
      else {
        tstr = secondsToString((long long)eta);
        out.append(tstr);
      }
    }

    // Pad end with spaces to overwrite previous string that may have been
    // longer.
    if (out.size() < width) out.append(width - out.size(), ' ');

    out.append("\r");
    std::cerr << out;
    std::cerr.flush();
  }

  unsigned int n;                ///< Total number of steps for progress.
  unsigned short pct;            ///< Current percentage (0-1000).
  unsigned int cur;              ///< Current progress count.
  unsigned char width;           ///< Width of the progress bar display.
  long long startTime, endTime;  ///< Timing information for ETA calculation.
#ifdef WIN32
  LARGE_INTEGER g_llFrequency;  ///< High-performance timer frequency.¯
#endif
};
}  // namespace ez
#endif  // EZ_ETAPROGRESSBAR_H
