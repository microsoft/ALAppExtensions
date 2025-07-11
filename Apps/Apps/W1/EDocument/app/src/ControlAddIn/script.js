var pdfDoc = null;
var pageNum = 1;
var pageRendering = false;
var canvas = null;
var ctx = null;
var resizeTimeout = null;

// Initialize PDF viewer when ControlAddIn is ready
function InitializeControl(controlId) {
    var controlAddIn = document.getElementById(controlId);
    controlAddIn.innerHTML = `
        <div id="edoc-pdf-contents">
            <div id="pdf-meta">
                <span id="page-count-container">
                    Page: <span id="page_num"></span> / <span id="page_count"></span>
                </span>
            </div>
            <div id="edoc-pdf-container">
                <canvas id="edoc-pdf-canvas"></canvas>
            </div>
        </div>
    `;

    // Assign canvas and context
    canvas = document.getElementById("edoc-pdf-canvas");
    ctx = canvas.getContext("2d");

    // Handle resize events
    window.addEventListener("mouseup", handleResizeEnd);
    window.addEventListener("touchend", handleResizeEnd);
}

// Convert Base64 PDF to Uint8Array and Render
function renderPDF(base64String, pageid) {

    // Loaded via <script> tag, create shortcut to access PDF.js exports.
    var { pdfjsLib } = globalThis;

    // The workerSrc property shall be specified.
    pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdn-bc.dynamics.com/common/js/pdfjs-4.10.38/pdf.worker.min.mjs';
    pageNum = pageid;

    var binaryString = atob(base64String);
    var len = binaryString.length;
    var bytes = new Uint8Array(len);
    for (var i = 0; i < len; i++) {
        bytes[i] = binaryString.charCodeAt(i);
    }

    var loadingTask = pdfjsLib.getDocument({ data: bytes });
    loadingTask.promise.then(function (pdf) {
        pdfDoc = pdf;
        document.getElementById("page_count").textContent = pdfDoc.numPages;
        renderPage(pageid); // Render first page initially
    }, function (reason) {
        // PDF loading error
        console.error(reason);
    });
}

// Render a specific page
function renderPage(num) {
    if (pageRendering || !pdfDoc) return;
    pageRendering = true;

    pdfDoc.getPage(num).then(function (page) {
        var scale = 1.5;
        var viewport = page.getViewport({ scale: scale, });
        // Support HiDPI-screens.
        var outputScale = window.devicePixelRatio || 1;

        canvas = document.getElementById("edoc-pdf-canvas");
        ctx = canvas.getContext("2d");

        canvas.width = Math.floor(viewport.width * outputScale);
        canvas.height = Math.floor(viewport.height * outputScale);

        var transform = outputScale !== 1
            ? [outputScale, 0, 0, outputScale, 0, 0]
            : null;

        // Ensure vertical scrolling works
        var pdfContainer = document.getElementById("edoc-pdf-container");
        pdfContainer.style.overflowY = "auto"; // Enable scrolling if needed
        pdfContainer.style.maxHeight = "100%"; // Prevent overflow issues

        var renderContext = {
            canvasContext: ctx,
            transform: transform,
            viewport: viewport
        };

        var renderTask = page.render(renderContext);
        renderTask.promise.then(function () {
            pageRendering = false;
            document.getElementById("page_num").textContent = num;
        });
    });
}

// Navigate to previous page
function PreviousPage() {
    if (pageNum <= 1) return;
    pageNum--;
    renderPage(pageNum);
}

// Navigate to next page
function NextPage() {
    if (pageNum >= pdfDoc.numPages) return;
    pageNum++;
    renderPage(pageNum);
}

// Calculate optimal scale based on Factbox width
function getOptimalScale() {
    var container = document.getElementById("edoc-pdf-contents");
    return container.clientWidth / 600; // Adjust based on Factbox width
}

// Resize event handler (triggers only after mouse release)
function handleResizeEnd() {
    if (resizeTimeout) clearTimeout(resizeTimeout);
    resizeTimeout = setTimeout(() => {
        renderPage(pageNum);
    }, 200);
}

// AL Calls these functions
function LoadPDF(PDFDocument) {
    renderPDF(PDFDocument, pageNum);
}

function SetVisible(IsVisible) {
    document.getElementById("edoc-pdf-contents").style.display = IsVisible ? "block" : "none";
}