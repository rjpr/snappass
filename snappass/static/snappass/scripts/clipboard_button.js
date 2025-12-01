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
        var originalTooltip = e.trigger.getAttribute('data-tooltip');
        e.trigger.setAttribute('data-tooltip', "Press " + key + "+C to copy");
        setTimeout(function() {
            e.trigger.setAttribute('data-tooltip', originalTooltip);
        }, 2000);
    };

    var copySuccess = function(e) {
        var img = e.trigger.querySelector('img');
        var originalTooltip = e.trigger.getAttribute('data-tooltip');
        var originalSrc = img.src;
        
        // Swap to check icon and update tooltip
        img.src = img.src.replace('copy.svg', 'check-big.svg');
        e.trigger.setAttribute('data-tooltip', 'Copied!');
        
        setTimeout(function() {
            img.src = originalSrc;
            e.trigger.setAttribute('data-tooltip', originalTooltip);
        }, 2000);
        e.clearSelection();
    };

    clipboard.on('success', copySuccess);
    clipboard.on('error', copyError);

})();