// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

pageextension 5283 "Audit Export Doc. Card SAF-T" extends "Audit File Export Doc. Card"
{
    layout
    {
        addafter(Contact)
        {
            field(ExportCurrencyInformation; Rec."Export Currency Information")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that currency information must be included in the export to the audit file.';
                Enabled = SAFTFormat;
                Visible = SAFTFormat;
            }
        }

        modify(Contact)
        {
            Enabled = not SAFTFormat;
            Visible = not SAFTFormat;
        }
    }

    trigger OnOpenPage()
    begin
        SAFTFormat := IsSAFTFormat();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SAFTFormat := IsSAFTFormat();
    end;

    var
        SAFTFormat: Boolean;

    local procedure IsSAFTFormat(): Boolean
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        AuditFileExportFormat: enum "Audit File Export Format";
        IsSAFTFormatSelected: Boolean;
    begin
        AuditFileExportFormat := Rec."Audit File Export Format";
        if AuditFileExportFormat = Enum::"Audit File Export Format"::None then     // if not initialized yet
            if AuditFileExportSetup.Get() then
                AuditFileExportFormat := AuditFileExportSetup."Audit File Export Format";
        IsSAFTFormatSelected := AuditFileExportFormat = Enum::"Audit File Export Format"::SAFT;
        exit(IsSAFTFormatSelected);
    end;
}
