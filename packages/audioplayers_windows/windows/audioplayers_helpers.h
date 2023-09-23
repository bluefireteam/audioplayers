constexpr int64_t c_msPerSecond = 1000;

template <typename SecondsT>
inline int64_t ConvertSecondsToMs(SecondsT seconds) {
  if (isinf(seconds))
    return 0;
  return static_cast<int64_t>(seconds * c_msPerSecond);
}

template <typename MsT>
inline double ConvertMsToSeconds(MsT ms) {
  return static_cast<double>(ms) / c_msPerSecond;
}
