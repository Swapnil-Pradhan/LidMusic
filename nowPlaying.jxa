function run() {
  try {
    const MediaRemote = $.NSBundle.bundleWithPath(
      "/System/Library/PrivateFrameworks/MediaRemote.framework/",
    );
    MediaRemote.load;
    const np = $.NSClassFromString(
      "MRNowPlayingRequest",
    ).localNowPlayingItem.nowPlayingInfo.valueForKey(
      "kMRMediaRemoteNowPlayingInfoPlaybackRate",
    ).js;
    return np;
  } catch (err) {
    return 0;
  }
}