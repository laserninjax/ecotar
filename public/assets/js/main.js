var fileDisposal = document.getElementById("fileDisposal");
fileDisposal.addEventListener("dragover", hover, false);
fileDisposal.addEventListener("dragleave", unhover, false);
fileDisposal.addEventListener("drop", unhover, false);

var avatarForm = document.getElementById("avatarForm");
avatarForm.addEventListener("submit", updateAvatar, false);

function hover() {
  fileDisposal.classList.add("hover");
};

function unhover() {
  fileDisposal.classList.remove("hover");
};

function updateAvatar(e) {
  e.preventDefault();
  avatarFrame = document.getElementById("avatarImage");
  avatarSeed = document.getElementById("avatarSeed");
  avatarFrame.setAttribute("src", "/avatar/" + avatarSeed.value);
};