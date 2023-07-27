codeunit 139513 "Create Stand. Data SAF-T Test" implements CreateStandardDataSAFT
{
    var
        TypeHelper: Codeunit "Type Helper";

    procedure LoadStandardAccounts(StandardAccountType: Enum "Standard Account Type") Result: Boolean;
    var
        GLAccount: Record "G/L Account";
        StandardAccount: Record "Standard Account";
        SAFTTestsHelper: Codeunit "SAF-T Tests Helper";
    begin
        StandardAccount.DeleteAll();
        GLAccount.SetRange("Account Type", "G/L Account Type"::Posting);
        GLAccount.FindSet();
        repeat
            SAFTTestsHelper.CreateStandardAccount(StandardAccountType, GLAccount."No.", GLAccount.Name);
        until GLAccount.Next() = 0;

        exit(true);
    end;

    procedure LoadStandardTaxCodes() Result: Boolean
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
        ImportAuditDataMgt: Codeunit "Import Audit Data Mgt.";
        CSVDocContent: Text;
        CRLF: Text[2];
        CSVFieldSeparator: Text[1];
    begin
        CSVFieldSeparator := ';';
        CRLF := TypeHelper.CRLFSeparator();
        CSVDocContent :=
            'TC1; Tax Code 1' + CRLF +
            'TC2; Tax Code 2' + CRLF +
            'TC3; Tax Code 3';
        ImportAuditDataMgt.LoadStandardAccountsFromCSVTextToCSVBuffer(TempCSVBuffer, CSVDocContent, CSVFieldSeparator);
        ImportStandardTaxCodesFromCSVBuffer(TempCSVBuffer);
        exit(true);
    end;

    procedure InitAuditExportDataTypeSetup()
    var
        AuditExportDataTypeSetup: Record "Audit Export Data Type Setup";
    begin
        AuditExportDataTypeSetup.DeleteAll(true);

        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::GeneralLedgerAccounts, "Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::Customers, "Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::Suppliers, "Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::TaxTable, "Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::UOMTable, "Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::AnalysisTypeTable, "Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::MovementTypeTable, "Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::Products, "Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::PhysicalStock, "Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::Assets, "Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::GeneralLedgerEntries, "Audit File Export Data Class"::GeneralLedgerEntries, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::SalesInvoices, "Audit File Export Data Class"::SourceDocuments, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::PurchaseInvoices, "Audit File Export Data Class"::SourceDocuments, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::Payments, "Audit File Export Data Class"::SourceDocuments, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::MovementOfGoods, "Audit File Export Data Class"::SourceDocuments, true);
        AuditExportDataTypeSetup.InsertRecord(
            "Audit File Export Format"::SAFT, "Audit File Export Data Type"::AssetTransactions, "Audit File Export Data Class"::SourceDocuments, true);
    end;

    local procedure ImportStandardTaxCodesFromCSVBuffer(var TempCSVBuffer: Record "CSV Buffer" temporary)
    var
        VATReportingCode: Record "VAT Reporting Code";
        TaxCode: Code[20];
        TaxCodeDescription: Text[250];
        LinesCount: Integer;
        LineNo: Integer;
        TaxCodeFieldNo: Integer;
        DescriptionFieldNo: Integer;
    begin
        if TempCSVBuffer.IsEmpty() then
            exit;

        TaxCodeFieldNo := 1;
        DescriptionFieldNo := 2;
        LinesCount := TempCSVBuffer.GetNumberOfLines();

        for LineNo := 1 to LinesCount do begin
            TaxCode := CopyStr(TempCSVBuffer.GetValue(LineNo, TaxCodeFieldNo), 1, MaxStrLen(VATReportingCode.Code));
            TaxCodeDescription := CopyStr(TempCSVBuffer.GetValue(LineNo, DescriptionFieldNo), 1, MaxStrLen(VATReportingCode.Description));

            VATReportingCode.Init();
            VATReportingCode.Code := TaxCode;
            VATReportingCode.Description := TaxCodeDescription;
            if VATReportingCode.Insert() then;
        end;
    end;
}