codeunit 11514 "Swiss QR-Bill Image Mgt."
{
    procedure GenerateSwissQRCodeImage(SourceText: Text; QRImageTempBlob: Codeunit "Temp Blob"): Boolean
    var
        SwissQRCodeHelper: Codeunit "Swiss QR Code Helper";
    begin
        exit(SwissQRCodeHelper.GenerateQRCodeImage(SourceText, QRImageTempBlob));
    end;
}
