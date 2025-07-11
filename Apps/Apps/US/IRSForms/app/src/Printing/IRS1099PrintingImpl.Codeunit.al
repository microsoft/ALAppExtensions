// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 10049 "IRS 1099 Printing Impl." implements "IRS 1099 Printing"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure SaveContentForDocument(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; IRS1099PrintParams: Record "IRS 1099 Print Params"; ReplaceIfExists: Boolean)
    var
        IRS1099FormReport: Record "IRS 1099 Form Report";
        IRS1099Print: Report "IRS 1099 Print";
        ReportOutStream: OutStream;
    begin
        if ContentForPrintingExists(IRS1099FormDocHeader, IRS1099PrintParams) and not ReplaceIfExists then
            exit;

        IRS1099FormReport.SetRange("Document ID", IRS1099FormDocHeader.ID);
        IRS1099FormReport.SetRange("Report Type", IRS1099PrintParams."Report Type");
        if not IRS1099FormReport.FindFirst() then begin
            IRS1099FormReport.Init();
            IRS1099FormReport.Validate("Document ID", IRS1099FormDocHeader.ID);
            IRS1099FormReport.Validate("Report Type", IRS1099PrintParams."Report Type");
            IRS1099FormReport.Insert();
        end;
        IRS1099FormReport."File Content".CreateOutStream(ReportOutStream);
        IRS1099FormDocHeader.SetRecFilter();
        IRS1099Print.SetTableView(IRS1099FormDocHeader);
        IRS1099Print.SetIRS1099FormReportType(IRS1099PrintParams."Report Type");
        IRS1099Print.SaveAs('', ReportFormat::Pdf, ReportOutStream);
        IRS1099FormReport.Modify();
    end;

    procedure PrintContent(IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    begin
        if not (IRS1099FormDocHeader.Status in ["IRS 1099 Form Doc. Status"::Released, "IRS 1099 Form Doc. Status"::Submitted]) then
            IRS1099FormDocHeader.FieldError(Status);
        IRS1099FormDocHeader.SetRecFilter();
        Report.Run(Report::"IRS 1099 Print", true, false, IRS1099FormDocHeader);
    end;

    local procedure ContentForPrintingExists(IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; IRS1099PrintParams: Record "IRS 1099 Print Params"): Boolean
    var
        IRS1099FormReport: Record "IRS 1099 Form Report";
    begin
        if not IRS1099FormReport.Get(IRS1099FormDocHeader.ID, IRS1099PrintParams."Report Type") then
            exit(false);
        IRS1099FormReport.CalcFields("File Content");
        exit(IRS1099FormReport."File Content".HasValue());
    end;
}
