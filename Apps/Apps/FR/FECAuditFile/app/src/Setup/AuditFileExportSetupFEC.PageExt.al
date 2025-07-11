// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

pageextension 10828 "Audit File Export Setup FEC" extends "Audit File Export Setup"
{
    layout
    {
        modify("Data Quality")
        {
            Enabled = not FECFormat;
            Visible = not FECFormat;
        }
    }

    var
        FECFormat: Boolean;

    trigger OnOpenPage()
    begin
        FECFormat := IsFECFormat();
    end;

    local procedure IsFECFormat(): Boolean
    var
        AuditFileExportFormat: Enum "Audit File Export Format";
    begin
        exit(Rec."Audit File Export Format" = AuditFileExportFormat::FEC);
    end;
}
