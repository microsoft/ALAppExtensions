codeunit 30253 "Shpfy OpenDoc NotSupported" implements "Shpfy IOpenShopifyDocument"
{

    procedure OpenDocument(DocumentId: BigInteger)
    var
        NotSupportedErr: Label 'Not Supported';
    begin
        Error(NotSupportedErr);
    end;

}