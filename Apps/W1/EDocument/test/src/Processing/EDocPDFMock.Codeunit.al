codeunit 139782 "E-Doc PDF Mock" implements IBlobType, IBlobToStructuredDataConverter, IStructuredFormatReader
{

    procedure IsStructured(): Boolean
    begin
        exit(false);
    end;

    procedure Convert(EDocument: Record "E-Document"; FromTempblob: Codeunit "Temp Blob"; FromType: Enum "E-Doc. Data Storage Blob Type"; var ConvertedType: Enum "E-Doc. Data Storage Blob Type"): Text
    begin
        ConvertedType := Enum::"E-Doc. Data Storage Blob Type"::JSON;
        exit('Mocked content');
    end;

    procedure HasConverter(): Boolean
    begin
        exit(true);
    end;

    procedure GetStructuredDataConverter(): Interface IBlobToStructuredDataConverter
    begin
        exit(this);
    end;

    procedure Read(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Structured Data Process"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
    begin
        if not EDocumentPurchaseHeader.Get(EDocument."Entry No") then begin
            EDocumentPurchaseHeader."E-Document Entry No." := EDocument."Entry No";
            EDocumentPurchaseHeader."Vendor VAT Id" := '1111111111234';
            EDocumentPurchaseHeader.Insert();
        end;
        exit(Enum::"E-Doc. Structured Data Process"::"Purchase Document");
    end;

}
