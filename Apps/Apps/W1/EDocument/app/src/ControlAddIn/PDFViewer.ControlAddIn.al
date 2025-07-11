controladdin "PDF Viewer"
{
    Scripts =
        'https://cdn-bc.dynamics.com/common/js/pdfjs-4.10.38/pdf.min.mjs',
        'script.js';

    StartupScript = 'startup.js';
    StyleSheets = 'stylesheet.css';

    HorizontalStretch = true;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalShrink = true;
    RequestedHeight = 800;

    event ControlAddinReady();
    procedure LoadPDF(PDFDocument: Text);
    procedure NextPage();
    procedure PreviousPage();
    procedure SetVisible(IsVisible: Boolean);
}