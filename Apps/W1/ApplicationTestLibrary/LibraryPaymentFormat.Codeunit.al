/// <summary>
/// Provides utility functions for creating and managing payment formats and data exchange definitions in test scenarios.
/// </summary>
codeunit 130101 "Library - Payment Format"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateDataExchDef(var DataExchDef: Record "Data Exch. Def"; DataHandlingCodeunit: Integer; ValidationCodeunit: Integer; ReadingWritingCodeunit: Integer; ReadingWritingXMLport: Integer; ExternalDataHandlingCodeunit: Integer; UserFeedbackCodeunit: Integer)
    begin
        DataExchDef.InsertRecForExport(
          LibraryUtility.GenerateGUID(), LibraryUtility.GenerateGUID(), DataExchDef.Type::"Payment Export".AsInteger(),
          ReadingWritingXMLport, DataExchDef."File Type"::"Variable Text");
        DataExchDef.Validate("Ext. Data Handling Codeunit", ExternalDataHandlingCodeunit);
        DataExchDef.Validate("Reading/Writing Codeunit", ReadingWritingCodeunit);
        DataExchDef.Validate("Validation Codeunit", ValidationCodeunit);
        DataExchDef.Validate("Data Handling Codeunit", DataHandlingCodeunit);
        DataExchDef.Validate("User Feedback Codeunit", UserFeedbackCodeunit);
        DataExchDef.Modify(true);
    end;

    procedure CreateDataExchColumnDef(var DataExchColumnDef: Record "Data Exch. Column Def"; DataExchDefCode: Code[20]; DataExchLineDefCode: Code[20])
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        DataExchColumnDef.InsertRec(DataExchDefCode, DataExchLineDefCode, 1, GenJnlLine.FieldCaption(Description),
          true, DataExchColumnDef."Data Type"::Text, '', '', GenJnlLine.FieldName(Description));
        DataExchColumnDef.InsertRec(DataExchDefCode, DataExchLineDefCode, 2, GenJnlLine.FieldCaption("Posting Date"),
          true, DataExchColumnDef."Data Type"::Date, '<Day,2><Month,2><Year4>', '', GenJnlLine.FieldName("Posting Date"));
        DataExchColumnDef.InsertRec(DataExchDefCode, DataExchLineDefCode, 3, GenJnlLine.FieldCaption(Amount),
          true, DataExchColumnDef."Data Type"::Decimal, '<Precision,2><sign><Integer><Decimals><Comma,.>', '',
          GenJnlLine.FieldName(Amount));
        DataExchColumnDef.Modify(true);
    end;

    procedure CreateDataExchMapping(var DataExchMapping: Record "Data Exch. Mapping"; DataExchDefCode: Code[20]; DataExchLineDefCode: Code[20]; PreMappingCodeunit: Integer; MappingCodeunit: Integer; PostMappingCodeunit: Integer)
    begin
        DataExchMapping.InsertRecForExport(DataExchDefCode, DataExchLineDefCode,
          DATABASE::"Payment Export Data", LibraryUtility.GenerateGUID(), MappingCodeunit);
        DataExchMapping.Validate("Pre-Mapping Codeunit", PreMappingCodeunit);
        DataExchMapping.Validate("Post-Mapping Codeunit", PostMappingCodeunit);
        DataExchMapping.Modify(true);
    end;

    procedure CreateDataExchFieldMapping(var DataExchFieldMapping: Record "Data Exch. Field Mapping"; DataExchDefCode: Code[20]; DataExchLineDefCode: Code[20])
    var
        PaymentExportData: Record "Payment Export Data";
    begin
        DataExchFieldMapping.InsertRec(DataExchDefCode, DataExchLineDefCode,
          DATABASE::"Payment Export Data", 1, PaymentExportData.FieldNo("Document No."), false, 0);
        DataExchFieldMapping.InsertRec(DataExchDefCode, DataExchLineDefCode,
          DATABASE::"Payment Export Data", 2, PaymentExportData.FieldNo("Transfer Date"), false, 0);
        DataExchFieldMapping.InsertRec(DataExchDefCode, DataExchLineDefCode,
          DATABASE::"Payment Export Data", 3, PaymentExportData.FieldNo(Amount), false, 1);
    end;

    procedure CreateBankExportImportSetup(var BankExportImportSetup: Record "Bank Export/Import Setup"; DataExchDef: Record "Data Exch. Def")
    begin
        BankExportImportSetup.Validate(Code, LibraryUtility.GenerateGUID());
        BankExportImportSetup.Validate(Name, DataExchDef.Name);
        BankExportImportSetup.Validate(Direction, BankExportImportSetup.Direction::Export);
        BankExportImportSetup.Validate("Data Exch. Def. Code", DataExchDef.Code);
        BankExportImportSetup.Insert(true);
    end;
}

