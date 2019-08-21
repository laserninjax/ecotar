const fileDisposal = document.getElementById("fileDisposal");
fileDisposal.addEventListener("dragover", hover, false);
fileDisposal.addEventListener("dragleave", unhover, false);
fileDisposal.addEventListener("drop", unhover, false);

const avatarForm = document.getElementById("avatarForm");
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

  loadInkStatus(function(data){
    for (const [key, value] of Object.entries(data)) {
      document.getElementById(key+"Ink").style.height = Math.log(value) / Math.log(2) * 4 + "px"
    }
  });
};

function loadInkStatus(callback) {
  var request = new XMLHttpRequest()

  // Open a new connection, using the GET request on the URL endpoint
  request.open('GET', '/ink_status.json', true)

  request.onload = function () {
    callback(JSON.parse(this.response))
  }

  request.send()
}
