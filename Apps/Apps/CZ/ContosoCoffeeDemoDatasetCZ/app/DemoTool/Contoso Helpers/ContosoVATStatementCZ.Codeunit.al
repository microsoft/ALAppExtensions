// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.Enums;

codeunit 31224 "Contoso VAT Statement CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "VAT Period CZL" = rim,
        tabledata "VAT Reports Configuration" = rim,
        tabledata "VAT Return Period" = rim,
        tabledata "VAT Statement Line" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertVatStatementLine(StatementTemplateName: Code[10]; StatementName: Code[10]; StatementLineNo: Integer; StatementRowNo: Code[10]; StatementLineType: Enum "VAT Statement Line Type"; GenPostingType: Enum "General Posting Type"; VatBusPostingGrp: Code[20]; VAtProdPostingGrp: Code[20]; RowTotaling: Text[50]; AmountType: Enum "VAT Statement Line Amount Type"; CalulationWith: Option; StatementPrint: Boolean; PrintWith: Option; StatementDesc: Text[100]; AccountTotaling: Text[30]; NewPage: Boolean; Show: Option; AttributeCode: Code[20]; VATControlRepSectionCode: Code[20]; BoxNo: Code[10])
    var
        VatStatementLine: Record "VAT Statement Line";
        Exists: Boolean;
    begin
        if VatStatementLine.Get(StatementTemplateName, StatementName, StatementLineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VatStatementLine.Validate("Statement Template Name", StatementTemplateName);
        VatStatementLine.Validate("Statement Name", StatementName);
        VatStatementLine.Validate("Line No.", StatementLineNo);
        VatStatementLine.Validate("Row No.", StatementRowNo);
        VatStatementLine.Validate(Description, StatementDesc);
        VatStatementLine.Validate(Type, StatementLineType);
        VatStatementLine.Validate("Account Totaling", AccountTotaling);
        VatStatementLine.Validate("Gen. Posting Type", GenPostingType);
        VatStatementLine.Validate("VAT Bus. Posting Group", VatBusPostingGrp);
        VatStatementLine.Validate("VAT Prod. Posting Group", VAtProdPostingGrp);
        VatStatementLine.Validate("Row Totaling", RowTotaling);
        VatStatementLine.Validate("Amount Type", AmountType);
        VatStatementLine.Validate("Calculate with", CalulationWith);
        VatStatementLine.Validate(Print, StatementPrint);
        VatStatementLine.Validate("Print with", PrintWith);
        VATStatementLine.Validate("New Page", NewPage);
        VATStatementLine.Validate("Show CZL", Show);
        VATStatementLine.Validate("Attribute Code CZL", AttributeCode);
        VATStatementLine.Validate("VAT Ctrl. Report Section CZL", VATControlRepSectionCode);
        VATStatementLine.Validate("Box No.", BoxNo);

        if Exists then
            VatStatementLine.Modify(true)
        else
            VatStatementLine.Insert(true);
    end;

    procedure InsertVATReportConfiguration(ReportConfig: Enum "VAT Report Configuration"; Version: Code[10]; SuggestCodeunit: Integer; ContentCodeunit: Integer; SubmissionCodeunit: Integer; ValidateCodeunit: Integer; VATStatementTemplate: Code[10]; VATStatementName: Code[10])
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
        Exists: Boolean;
    begin
        if VATReportsConfiguration.Get(ReportConfig, Version) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATReportsConfiguration.Validate("VAT Report Type", ReportConfig);
        VATReportsConfiguration.Validate("VAT Report Version", Version);
        VATReportsConfiguration.Validate("Suggest Lines Codeunit ID", SuggestCodeunit);
        VATReportsConfiguration.Validate("Validate Codeunit ID", ValidateCodeunit);
        VATReportsConfiguration.Validate("Content Codeunit ID", ContentCodeunit);
        VATReportsConfiguration.Validate("Submission Codeunit ID", SubmissionCodeunit);
        VATReportsConfiguration.Validate("VAT Statement Template", VATStatementTemplate);
        VATReportsConfiguration.Validate("VAT Statement Name", VATStatementName);

        if Exists then
            VATReportsConfiguration.Modify(true)
        else
            VATReportsConfiguration.Insert(true);
    end;

    procedure InsertVATPeriod(StartingDate: Date)
    var
        VATPeriodCZL: Record "VAT Period CZL";
        Exists: Boolean;
    begin
        if VATPeriodCZL.Get(StartingDate) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATPeriodCZL.Validate("Starting Date", StartingDate);
        if (Date2DMY(StartingDate, 1) = 1) and (Date2DMY(StartingDate, 2) = 1) then
            VATPeriodCZL."New VAT Year" := true;

        if Exists then
            VATPeriodCZL.Modify(true)
        else
            VATPeriodCZL.Insert(true);
    end;

    procedure InsertVATReturnPeriod(StartingDate: Date; EndDate: Date; DueDate: Date)
    var
        VATReturnPeriod: Record "VAT Return Period";
        Exists: Boolean;
    begin
        VATReturnPeriod.SetRange("Start Date", StartingDate);
        VATReturnPeriod.SetRange("End Date", EndDate);
        if VATReturnPeriod.FindFirst() then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        VATReturnPeriod.Validate("Start Date", StartingDate);
        VATReturnPeriod.Validate("End Date", EndDate);
        VATReturnPeriod.Validate("Due Date", DueDate);

        if Exists then
            VATReturnPeriod.Modify(true)
        else
            VATReturnPeriod.Insert(true);
    end;
}
