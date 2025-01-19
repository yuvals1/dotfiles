// ==UserScript==
// @name         Ctrl+U Line Clear
// @namespace    http://tampermonkey.net/
// @version      0.6
// @description  Unix-style Ctrl+U with better node handling
// @author       You
// @match        *://*/*
// @grant        none
// ==/UserScript==

(function () {
  "use strict";

  document.addEventListener("keydown", function (e) {
    if (e.ctrlKey && e.key === "u") {
      e.preventDefault();

      const el = document.activeElement;

      if (el.isContentEditable) {
        const selection = window.getSelection();
        const range = selection.getRangeAt(0);
        const offset = range.startOffset;
        const container = range.startContainer;

        // If we're at the start of a node
        if (offset === 0) {
          // Get the previous text node
          let node = container;
          let previousNode = null;

          // Walk the DOM backwards
          while (node !== el) {
            while (node.previousSibling) {
              node = node.previousSibling;
              // Find the last text node in this branch
              while (node.lastChild) {
                node = node.lastChild;
              }
              if (node.nodeType === 3) {
                // Text node
                previousNode = node;
                break;
              }
            }
            if (previousNode) break;
            node = node.parentNode;
          }

          // If we found a previous text node, move to its end
          if (previousNode) {
            range.setStart(previousNode, previousNode.length);
            range.setEnd(previousNode, previousNode.length);
            selection.removeAllRanges();
            selection.addRange(range);
            return;
          }
        }

        // Normal case: delete to start of line
        const text = container.textContent;
        const textBeforeCursor = text.substring(0, offset);
        const lastNewlineIndex = textBeforeCursor.lastIndexOf("\n");
        const lineStart = lastNewlineIndex + 1;

        container.textContent =
          text.substring(0, lineStart) + text.substring(offset);
        range.setStart(container, lineStart);
        range.setEnd(container, lineStart);
        selection.removeAllRanges();
        selection.addRange(range);
      }
    }
  });
})();
