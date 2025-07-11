// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.VAT.Reporting;
using System.IO;

codeunit 13687 "Create Standard Data SAF-T DK" implements CreateStandardDataSAFT
{
    Access = Internal;

    procedure LoadStandardAccounts(StandardAccountType: Enum "Standard Account Type") Result: Boolean;
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
        StandardAccountDK: Codeunit "Standard Account DK";
        ImportAuditDataMgt: Codeunit "Import Audit Data Mgt.";
        CSVDocContent: Text;
        CSVFieldSeparator: Text[1];
    begin
        CSVFieldSeparator := ';';
        CSVDocContent := StandardAccountDK.GetStandardAccountsCSV();
        if CSVDocContent = '' then
            exit(false);
        ImportAuditDataMgt.LoadStandardAccountsFromCSVTextToCSVBuffer(TempCSVBuffer, CSVDocContent, CSVFieldSeparator);

        if TempCSVBuffer.IsEmpty() then
            exit(false);
        ImportAuditDataMgt.ImportStandardAccountsFromCSVBuffer(TempCSVBuffer, StandardAccountType);

        exit(true);
    end;

    procedure LoadStandardTaxCodes() Result: Boolean
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
        StandardTaxCodeDK: Codeunit "Standard Tax Code DK";
        ImportAuditDataMgt: Codeunit "Import Audit Data Mgt.";
        CSVDocContent: Text;
        CSVFieldSeparator: Text[1];
    begin
        CSVFieldSeparator := ';';
        CSVDocContent := StandardTaxCodeDK.GetStandardTaxCodesCSV();
        if CSVDocContent = '' then
            exit(false);
        ImportAuditDataMgt.LoadStandardAccountsFromCSVTextToCSVBuffer(TempCSVBuffer, CSVDocContent, CSVFieldSeparator);

        if TempCSVBuffer.IsEmpty() then
            exit(false);
        ImportStandardTaxCodesFromCSVBuffer(TempCSVBuffer);

        exit(true);
    end;

    procedure InitAuditExportDataTypeSetup()
    var
        AuditExportDataTypeSetup: Record "Audit Export Data Type Setup";
    begin
        AuditExportDataTypeSetup.DeleteAll(true);

        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::GeneralLedgerAccounts, Enum::"Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::Customers, Enum::"Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::Suppliers, Enum::"Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::TaxTable, Enum::"Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::UOMTable, Enum::"Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::AnalysisTypeTable, Enum::"Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::MovementTypeTable, Enum::"Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::Products, Enum::"Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::PhysicalStock, Enum::"Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::Assets, Enum::"Audit File Export Data Class"::MasterData, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::GeneralLedgerEntries, Enum::"Audit File Export Data Class"::GeneralLedgerEntries, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::SalesInvoices, Enum::"Audit File Export Data Class"::SourceDocuments, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::PurchaseInvoices, Enum::"Audit File Export Data Class"::SourceDocuments, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::Payments, Enum::"Audit File Export Data Class"::SourceDocuments, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::MovementOfGoods, Enum::"Audit File Export Data Class"::SourceDocuments, true);
        AuditExportDataTypeSetup.InsertRecord(
            Enum::"Audit File Export Format"::SAFT, Enum::"Audit File Export Data Type"::AssetTransactions, Enum::"Audit File Export Data Class"::SourceDocuments, true);
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
