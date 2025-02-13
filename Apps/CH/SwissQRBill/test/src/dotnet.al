dotnet
{
    assembly(Microsoft.Dynamics.Nav.MX)
    {

        type(Microsoft.Dynamics.QRCode.ErrorCorrectionLevel; "Swiss QR-Bill Error Correction Level") { }
        type(Microsoft.Dynamics.Nav.MX.BarcodeProviders.IBarcodeProvider; "Swiss QR-Bill IBarcode Provider") { }
        type(Microsoft.Dynamics.Nav.MX.BarcodeProviders.QRCodeProvider; "Swiss QR-Bill QRCode Provider") { }
    }
}
