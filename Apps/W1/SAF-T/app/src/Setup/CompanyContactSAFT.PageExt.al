// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Foundation.Company;

pageextension 5280 "Company Contact SAF-T" extends "Company Information"
{
    layout
    {
        addlast(Communication)
        {
            field(SAFTContactNo; Rec."Contact No. SAF-T")
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies the employee of the company whose information will be exported as the contact for the SAF-T file.';
                ShowMandatory = FieldIsMandatory;
                Enabled = SAFTFormat;
                Visible = SAFTFormat;
            }
        }
        modify("VAT Registration No.")
        {
            ShowMandatory = FieldIsMandatory;
        }
    }

    var
        FieldIsMandatory: Boolean;
        SAFTFormat: Boolean;

    trigger OnOpenPage()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
    begin
        if AuditFileExportSetup.Get() then;
        FieldIsMandatory := AuditFileExportSetup."Check Company Information";
        SAFTFormat := AuditFileExportSetup."Audit File Export Format" = Enum::"Audit File Export Format"::SAFT;
    end;
}
