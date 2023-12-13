// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Foundation.Period;

codeunit 5317 "Data Check SIE" implements "Audit File Export Data Check"
{
    var
        AccPeriodForStartingDateNotFoundErr: Label 'The starting date %1 must be within the existing accounting period.', Comment = '%1 - starting date of the audit file export document';
        NextAccPeriodForStartingDateNotFoundErr: Label 'There must be the accounting period next to the accounting period %1.', Comment = '%1 - starting date of accounting period';

    procedure CheckDataToExport(var AuditFileExportHeader: Record "Audit File Export Header"): enum "Audit Data Check Status"
    begin
    end;

    procedure CheckAuditDocReadyToExport(var AuditFileExportHeader: Record "Audit File Export Header"): enum "Audit Data Check Status"
    var
        AccountingPeriod: Record "Accounting Period";
        AccPeriodStart: Date;
        AccPeriodEnd: Date;
    begin
        AuditFileExportHeader.TestField("File Type");
        AuditFileExportHeader.TestField("Starting Date");
        AuditFileExportHeader.TestField("Ending Date");

        AccPeriodStart := AccountingPeriod.GetFiscalYearStartDate(AuditFileExportHeader."Starting Date");
        if AccPeriodStart = 0D then
            Error(AccPeriodForStartingDateNotFoundErr, AuditFileExportHeader."Starting Date");
        AccPeriodEnd := AccountingPeriod.GetFiscalYearEndDate(AuditFileExportHeader."Starting Date");
        if AccPeriodEnd = 0D then
            Error(NextAccPeriodForStartingDateNotFoundErr, AccPeriodStart);

        exit(Enum::"Audit Data Check Status"::Passed);
    end;
}
