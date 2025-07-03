/*
 * activate modal with login form
 * or logout user 
 */
function showModal() {
    document.getElementById("download-modal").style.display = "block";
    downloadXmlFiles();
}

function downloadXmlFiles() {
    const xhr = new XMLHttpRequest();
    xhr.open("GET", "download-xml", true); // assuming controller handles `download-xml`
    xhr.responseType = "json"; // very important!
    xhr.onload = async function () {
        if (xhr.status === 200) {
            const zip = new JSZip();
            const files = xhr.response; // use .responseText if not a blob
            const filteredFiles = files.filter(f => 
                !f.endsWith('.xql') && f !== '__contents__.xml'
            );
            const totalFiles = filteredFiles.length;

            const progressLabel = document.getElementById("download-progress-label");
            const currentFileLabel = document.getElementById("current-file-label");
            const progressBar = document.getElementById("progress-bar");

            for (let i = 0; i < totalFiles; i++) {
                const file = filteredFiles[i];
                
                if (!file.endsWith(".xml"))
                    continue; // skip non-XML files

                progressLabel.textContent = `Downloading file ${i + 1} of ${totalFiles}`;
                currentFileLabel.textContent = `Currently downloading: ${file}`;

                let resp = await fetch(`http://localhost:8080/data/${encodeURIComponent(file)}`)
                let xml = await resp.text();
                zip.file(file, xml);

                // Update progress bar
                const percent = Math.round(((i + 1) / totalFiles) * 100);
                progressBar.style.width = `${percent}%`;
                progressBar.textContent = `${percent}%`;
            }

            // Create zip and trigger download
            progressLabel.textContent = "Creating ZIP...";
            currentFileLabel.textContent = "";

            // Step 3: Generate ZIP and trigger download
            zip.generateAsync({ type: "blob" }).then(function (blob) {
                const link = document.createElement("a");
                link.href = URL.createObjectURL(blob);
                link.download = "xml-files.zip";
                link.click();

                progressLabel.textContent = "Download complete!";
                currentFileLabel.textContent = "";
                progressBar.style.width = "100%";
                progressBar.textContent = "100%";

                // Optional: close the modal after a delay
                setTimeout(closeModal, 2000);
            });
        } else {
            console.error("Download failed:", xhr.statusText);
        }
    };
    xhr.send();
}

/*
 * close the modal on request
 * and download on submit
 */
function closeModal() {
    document.getElementById("download-modal").style.display = "none";
}


document.getElementById("download-files").addEventListener("click", showModal, false);
document.querySelectorAll(".close-modal").forEach(el => { el.addEventListener("click", closeModal, false) });

/*
 * add (main) event listener on load and on focus change
 * this will trigger and propagate 
 * all changes to login form and buttons
 */
// window.addEventListener("focus", ajaxLogin);
// window.addEventListener("load", ajaxLogin);

/*
 * close modal on escape key press
 */
document.addEventListener('keydown', evt => {
    if (evt.key === 'Escape') {
        document.getElementById("login-modal").style.display = "none";
    }
});
