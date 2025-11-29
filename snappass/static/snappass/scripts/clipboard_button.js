(function(){

    var targetButtonSelector = '#copy-clipboard-btn'
    var clipboard = new ClipboardJS(targetButtonSelector);

    var copyError = function(e) {
        var key;
        if (/Mac/i.test(navigator.userAgent)) {
          key = '⌘';
        } else {
          key = 'Ctrl';
        }
        var originalText = e.trigger.textContent;
        e.trigger.textContent = "Press " + key + "+C to copy";
        setTimeout(function() {
            e.trigger.textContent = originalText;
        }, 2000);
    };

    var copySuccess = function(e) {
        var originalText = e.trigger.textContent;
        e.trigger.textContent = '✓ Copied!';
        setTimeout(function() {
            e.trigger.textContent = originalText;
        }, 2000);
        e.clearSelection();
    };

    clipboard.on('success', copySuccess);
    clipboard.on('error', copyError);

})();