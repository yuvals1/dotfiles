// ==UserScript==
// @name         Copy YouTube Video Title and Uploader
// @namespace    http://tampermonkey.net/
// @version      0.3
// @description  Copy the current YouTube video title and uploader name to clipboard using 'Y' key
// @match        https://www.youtube.com/*
// @grant        none
// ==/UserScript==

(function () {
  "use strict";
  document.addEventListener("keydown", function (e) {
    // Use 'Y' key
    if (e.key === "Y") {
      let videoTitleElement = document.querySelector(
        "h1.ytd-video-primary-info-renderer",
      );
      let uploaderNameElement = document.querySelector("ytd-channel-name a");
      if (videoTitleElement && uploaderNameElement) {
        let videoTitle = videoTitleElement.textContent.trim();
        let uploaderName = uploaderNameElement.textContent.trim();
        let textToCopy = `${uploaderName}: ${videoTitle}`;
        navigator.clipboard
          .writeText(textToCopy)
          .then(() => {
            console.log("Video title and uploader name copied to clipboard");
            showCopiedMessage();
          })
          .catch((err) => console.error("Failed to copy: ", err));
      } else {
        console.error(
          "Could not find video title or uploader name on the page.",
        );
      }
    }
  });

  function showCopiedMessage() {
    let message = document.createElement("div");
    message.textContent = "Video title and uploader name copied!";
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
