// ==UserScript==
// @name         Copy YouTube Video Title
// @namespace    http://tampermonkey.net/
// @version      0.2
// @description  Copy the current YouTube video title to clipboard using Ctrl+Shift+C
// @match        https://www.youtube.com/*
// @grant        none
// ==/UserScript==

(function () {
  "use strict";

  document.addEventListener("keydown", function (e) {
    // Use Ctrl+Shift+C combination
    if (e.key === "Y") {
      let videoTitle = document.querySelector(
        "h1.ytd-video-primary-info-renderer",
      );
      if (videoTitle) {
        navigator.clipboard
          .writeText(videoTitle.textContent.trim())
          .then(() => {
            console.log("Video title copied to clipboard");
            showCopiedMessage();
          })
          .catch((err) => console.error("Failed to copy: ", err));
      }
    }
  });

  function showCopiedMessage() {
    let message = document.createElement("div");
    message.textContent = "Video title copied!";
    message.style.cssText = `
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            z-index: 9999;
        `;
    document.body.appendChild(message);
    setTimeout(() => {
      message.remove();
    }, 2000);
  }
})();
