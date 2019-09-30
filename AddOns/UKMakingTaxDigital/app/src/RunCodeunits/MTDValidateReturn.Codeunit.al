// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10533 "MTD Validate Return"
{
    TableNo = "VAT Report Header";

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"VAT Report Validate", Rec);
        ValidateVATReport(Rec);
    end;

    local procedure ValidateVATReport(VATReportHeader: Record "VAT Report Header")
    var
        VATReportSetup: Record "VAT Report Setup";
        CompanyInformation: Record "Company Information";
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetContext(VATReportHeader);
        with VATReportSetup do begin
            Get();
            ErrorMessage.ClearLogRec(VATReportSetup);
            ErrorMessage.LogIfEmpty(VATReportSetup, FIELDNO("Report Version"), ErrorMessage."Message Type"::Error);
        end;

        with CompanyInformation do begin
            Get();
            ErrorMessage.ClearLogRec(CompanyInformation);
            ErrorMessage.LogIfEmpty(CompanyInformation, FIELDNO("VAT Registration No."), ErrorMessage."Message Type"::Error);
        end;
    end;
}
