// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Foundation.Company;
using System.Utilities;
using Microsoft.Finance.VAT.Reporting;

codeunit 10510 "GovTalk Validate VAT Report"
{
    TableNo = "VAT Report Header";
    trigger OnRun()
    begin
        CODEUNIT.Run(CODEUNIT::"VAT Report Validate", Rec);
        ValidateGovTalkPrerequisites(Rec);
    end;

    var
        GovTalkSetupMissingErr: Label 'The GovTalk service is not completely set up. If you want to submit the report, go to the Service Connection page and fill in the the GovTalk setup fields.';

    [Scope('OnPrem')]
    procedure ValidateGovTalkPrerequisites(VATReportHeader: Record "VAT Report Header"): Boolean
    var
        ErrorMessage: Record "Error Message";
        TempErrorMessage: Record "Error Message" temporary;
        GovTalkSetup: Record "Gov Talk Setup";
        CompanyInformation: Record "Company Information";
    begin
        ErrorMessage.SetContext(VATReportHeader);

        ErrorMessage.ClearLogRec(CompanyInformation);
        CompanyInformation.Get();
        ErrorMessage.LogIfEmpty(CompanyInformation, CompanyInformation.FieldNo("Country/Region Code"), ErrorMessage."Message Type"::Error);
        ErrorMessage.LogIfEmpty(CompanyInformation, CompanyInformation.FieldNo("VAT Registration No."), ErrorMessage."Message Type"::Error);
        if VATReportHeader."VAT Report Config. Code" = VATReportHeader."VAT Report Config. Code"::"EC Sales List" then begin
            ErrorMessage.LogIfEmpty(CompanyInformation, CompanyInformation.FieldNo("Branch Number GB"), ErrorMessage."Message Type"::Error);
            ErrorMessage.LogIfEmpty(CompanyInformation, CompanyInformation.FieldNo("Post Code"), ErrorMessage."Message Type"::Error);
        end;
        ErrorMessage.CopyToTemp(TempErrorMessage);

        ErrorMessage.ClearLogRec(GovTalkSetup);
        if not GovTalkSetup.FindFirst() then
            ErrorMessage.LogSimpleMessage(ErrorMessage."Message Type"::Error, GovTalkSetupMissingErr)
        else
            if (GovTalkSetup.Username = '') or IsNullGuid(GovTalkSetup.Password) or (GovTalkSetup.Endpoint = '') then
                ErrorMessage.LogMessage(GovTalkSetup, GovTalkSetup.FieldNo(Username), ErrorMessage."Message Type"::Warning, GovTalkSetupMissingErr);
        ErrorMessage.CopyToTemp(TempErrorMessage);

        exit(not TempErrorMessage.HasErrors(false));
    end;
}

