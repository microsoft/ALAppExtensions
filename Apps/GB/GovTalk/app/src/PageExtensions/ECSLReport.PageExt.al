// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.Company;
using System.Utilities;

pageextension 10504 "ECSL Report" extends "ECSL Report"
{
    layout
    {
        modify(ErrorMessagesPart)
        {
            Caption = 'Errors and Warnings';
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        GovTalkSetup: Record "Gov Talk Setup";
#if not CLEAN27
        GovTalk: Codeunit GovTalk;
#endif
    begin
#if not CLEAN27
        if not GovTalk.IsEnabled() then
            exit;
#endif
        DeleteErrors(DummyCompanyInformation.RecordId);
        DeleteErrors(GovTalkSetup.RecordId);
    end;

    var
        DummyCompanyInformation: Record "Company Information";

    local procedure DeleteErrors(Context: RecordID)
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetRange("Context Record ID", Context);
        if ErrorMessage.FindFirst() then
            ErrorMessage.DeleteAll(true);
        Commit();
    end;
}