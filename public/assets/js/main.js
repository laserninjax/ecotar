var fileDisposal = document.getElementById("fileDisposal");
fileDisposal.addEventListener("dragover", hover, false);
fileDisposal.addEventListener("dragleave", unhover, false);
fileDisposal.addEventListener("drop", unhover, false);

function hover() {
  fileDisposal.classList.add("hover");
};

function unhover() {
  fileDisposal.classList.remove("hover");
};