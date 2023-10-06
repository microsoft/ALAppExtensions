namespace Microsoft.Integration.Shopify;

codeunit 30252 "Shpfy OpenBCDoc NotSupported" implements "Shpfy IOpenBCDocument"
{
    var
        NotSupportedErr: Label 'Not Supported';

    procedure OpenDocument(DocumentNo: Code[20])
    begin
        Error(NotSupportedErr);
    end;
}