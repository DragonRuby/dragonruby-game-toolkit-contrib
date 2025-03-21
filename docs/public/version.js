window.dragonruby ||= {}

function set_version(retry_count) {
  fetch("/version.txt").then(r => r.text())
    .then(v => {
      window.dragonruby.version = v.trim()
      let div = document.createElement("div")
      div.style = "color: #f5f5f5; font-size: 16px;"
      div.innerHTML = `v${v}`
      let h1 = document.querySelector(".app-name")
      if (h1) h1.appendChild(div)
      else if (retry_count < 3) set_version_on_timeout(retry_count + 1)
    })
}

function set_version_on_timeout(retry_count) {
  setTimeout(() => {
    set_version()
  }, 500 * retry_count)
}

set_version(0)
