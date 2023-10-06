// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

using Microsoft.Finance.AuditFileExport;

pageextension 10689 "SAF-T Company Contact" extends "Company Information"
{
    layout
    {
        addlast(Communication)
        {
            field(SAFTContactNo; "SAF-T Contact No.")
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies the employee of the company whose information will be exported as the contact for the SAF-T file.';
                ShowMandatory = FieldIsMandatory;
            }
        }
        modify("VAT Registration No.")
        {
            ShowMandatory = FieldIsMandatory;
        }
    }

    var
        FieldIsMandatory: Boolean;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SAFTDataCheck: Codeunit "SAF-T Data Check";
    begin
        if FieldIsMandatory then
            exit(SAFTDataCheck.ThrowNotificationIfCompanyInformationDataMissed(Rec));
        exit(true);
    end;

    trigger OnOpenPage()
    var
        SAFTSetup: Record "SAF-T Setup";
    begin
        if SAFTSetup.Get() then;
        FieldIsMandatory := SAFTSetup."Check Company Information";
    end;
}
