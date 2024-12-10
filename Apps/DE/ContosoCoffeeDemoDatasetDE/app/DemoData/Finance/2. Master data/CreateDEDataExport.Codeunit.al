codeunit 11122 "Create DE Data Export"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoDEDigitalAudit: Codeunit "Contoso DE Digital Audit";
    begin
        ContosoDEDigitalAudit.InsertDataExport(ExportData(), ExportDataLbl);
        ContosoDEDigitalAudit.InsertDataExport(FixedAssetData(), FixedAssetDataLbl);
        ContosoDEDigitalAudit.InsertDataExport(GLAccountData(), GLAccountDataLbl);
        ContosoDEDigitalAudit.InsertDataExport(ItemData(), ItemDataLbl);
    end;

    procedure ExportData(): Code[10]
    begin
        exit(ExportDataTok);
    end;

    procedure FixedAssetData(): Code[10]
    begin
        exit(FixedAssetDataTok);
    end;

    procedure GLAccountData(): Code[10]
    begin
        exit(GLAccountDataTok);
    end;

    procedure ItemData(): Code[10]
    begin
        exit(ItemDataTok);
    end;

    var
        ExportDataTok: Label 'EXPORT-1', MaxLength = 10;
        FixedAssetDataTok: Label 'FAACC 2022', MaxLength = 10;
        GLAccountDataTok: Label 'GLACC 2022', MaxLength = 10;
        ItemDataTok: Label 'ITEM 2022', MaxLength = 10;
        ExportDataLbl: Label 'Definition Group for EXPORT-1', MaxLength = 50;
        FixedAssetDataLbl: Label 'Required data for exporting Fixed Asset data', MaxLength = 50;
        GLAccountDataLbl: Label 'Required data for exporting G/L and personal data', MaxLength = 50;
        ItemDataLbl: Label 'Required data for exporting Item and Invoice data', MaxLength = 50;
}