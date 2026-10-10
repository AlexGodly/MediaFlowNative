const webExportBridge = r'''
(function () {
  if (window.__mfAppExportBridgeInstalled) return;
  window.__mfAppExportBridgeInstalled = true;
  if (location.origin !== 'https://alexgodly.github.io' ||
      !location.pathname.startsWith('/MediaFlow')) return;
  document.addEventListener('click', async function (event) {
    const target = event.target;
    const anchor = target && target.closest && target.closest('a[download]');
    if (!anchor) return;
    const href = anchor.href || '';
    if (!href.startsWith('blob:') && !href.startsWith('data:')) return;
    const channel = window.flutter_inappwebview;
    if (!channel || typeof channel.callHandler !== 'function') return;
    event.preventDefault();
    event.stopImmediatePropagation();
    let transferId = null;
    try {
      const response = await fetch(href);
      if (!response.ok) throw new Error('Export data could not be read');
      const blob = await response.blob();
      transferId = await channel.callHandler(
        'mfBeginExport', anchor.download || 'MediaFlow-export.json', blob.size);
      const batch = 128 * 1024;
      for (let offset = 0; offset < blob.size; offset += batch) {
        const piece = blob.slice(offset, offset + batch);
        const encoded = await new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.onerror = () => reject(reader.error || new Error('Export read failed'));
          reader.onload = () => resolve(String(reader.result).split(',')[1]);
          reader.readAsDataURL(piece);
        });
        await channel.callHandler('mfAppendExport', transferId, encoded);
      }
      const result = await channel.callHandler('mfFinishExport', transferId);
      if (result !== true) throw new Error('Save cancelled or failed');
    } catch (error) {
      if (transferId != null) {
        try { await channel.callHandler('mfCancelExport', transferId); } catch (_) {}
      }
      window.alert('Could not save the MediaFlow export: ' + (error.message || error));
    }
  }, true);
})();
''';
