codeunit 139782 "E-Doc PDF Mock" implements IStructureReceivedEDocument, IStructuredDataType, IStructuredFormatReader
{

    procedure ReadIntoDraft(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Process Draft"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
    begin
        if not EDocumentPurchaseHeader.Get(EDocument."Entry No") then begin
            EDocumentPurchaseHeader."E-Document Entry No." := EDocument."Entry No";
            EDocumentPurchaseHeader."Vendor VAT Id" := '1111111111234';
            EDocumentPurchaseHeader.Insert();
        end;
        exit(Enum::"E-Doc. Process Draft"::"Purchase Document");
    end;

    procedure View(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob")
    begin

    end;

    procedure StructureReceivedEDocument(EDocumentDataStorage: Record "E-Doc. Data Storage"): Interface IStructuredDataType
    begin
        exit(this);
    end;

    procedure GetFileFormat(): Enum "E-Doc. File Format"
    begin
        exit(Enum::"E-Doc. File Format"::JSON); // file format of the converted structured data (JSON)
    end;

    procedure GetContent(): Text
    begin
        exit('Mocked content');
    end;

    procedure GetReadIntoDraftImpl(): Enum "E-Doc. Read into Draft"
    begin
        exit("E-Doc. Read into Draft"::Unspecified);
    end;

}
