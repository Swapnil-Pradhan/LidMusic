function run(argv) {
  const url = "https://github.com/Swapnil-Pradhan/LidMusic";
  Safari.activate();
  Safari.openLocation(url);
  const cssPath = argv[0];

  const app = Application.currentApplication();
  app.includeStandardAdditions = true;
  const Safari = Application("Safari");
  const css = app.read(Path(cssPath)).replace(/`/g, "\\`");

  

  const tab = (() => {
    const w = Safari.windows[0];
    return w && w.currentTab ? w.currentTab : Safari.windows[0].tabs[0];
  })();

  const max = 60;
  let i = 0;
  while (i++ < max) {
    try {
      const u = tab.url();
      if (u && u !== "about:blank") break;
    } catch (e) {}
    delay(0.1);
  }

  const js =
    "var s=document.createElement('style');s.type='text/css';s.innerHTML=`" +
    css +
    "`;document.head.appendChild(s);";
  Safari.doJavaScript(js, { in: tab });
}