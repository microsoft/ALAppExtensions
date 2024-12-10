codeunit 11124 "Create DE Data Exp. Rec. Type"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoDEDigitalAudit: Codeunit "Contoso DE Digital Audit";
    begin
        ContosoDEDigitalAudit.InsertDataExportRecordType(RecordCode(), RecordCodeLbl);
        ContosoDEDigitalAudit.InsertDataExportRecordType(FixedAssetData(), FixedAssetDataLbl);
        ContosoDEDigitalAudit.InsertDataExportRecordType(GLAccountData(), GLAccountDataLbl);
        ContosoDEDigitalAudit.InsertDataExportRecordType(ItemData(), ItemDataLbl);
    end;

    procedure RecordCode(): Code[10]
    begin
        exit(RecordCodeTok);
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
        RecordCodeTok: Label 'RECORD-1', MaxLength = 10;
        FixedAssetDataTok: Label 'FAACC 2022', MaxLength = 10;
        GLAccountDataTok: Label 'GLACC 2022', MaxLength = 10;
        ItemDataTok: Label 'ITEM 2022', MaxLength = 10;
        RecordCodeLbl: Label 'Record Code 1', MaxLength = 50;
        FixedAssetDataLbl: Label 'Required data for exporting Fixed Asset data', MaxLength = 50;
        GLAccountDataLbl: Label 'Required data for exporting G/L and personal data', MaxLength = 50;
        ItemDataLbl: Label 'Required data for exporting Item and Invoice data', MaxLength = 50;
}