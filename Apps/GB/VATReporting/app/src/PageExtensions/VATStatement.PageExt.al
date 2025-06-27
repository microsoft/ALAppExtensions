// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace VATReporting.VATReporting;

using Microsoft.Finance.VAT.Reporting;

pageextension 10548 "VAT Statement" extends "VAT Statement"
{
    actions
    {
#if not CLEAN27
#pragma warning disable AL0432
        modify("VAT Audit Report")
#pragma warning restore AL0432
        {
            Visible = not IsNewFeatureEnabled;
        }
#pragma warning disable AL0432
        modify("VAT Entry Exception Report")
#pragma warning restore AL0432
        {
            Visible = not IsNewFeatureEnabled;
        }
#endif
        addfirst(reporting)
        {
            action("VAT Audit Report GB")
            {
                ApplicationArea = VAT;
                Caption = 'VAT Audit Report';
                Image = "Report";
                RunObject = Report "VAT Audit GB";
                ToolTip = 'Export the data required for auditing in a comma-separated value (CSV) file format.';
#if not CLEAN27
                Visible = IsNewFeatureEnabled;
                Enabled = IsNewFeatureEnabled;
#endif
            }
            action("VAT Entry Exception Report GB")
            {
                ApplicationArea = VAT;
                Caption = 'VAT Entry Exception Report';
                Image = "Report";
                RunObject = Report "VAT Entry Exception Report GB";
                ToolTip = 'Print the Exception report so that you can document and show differences in VAT amounts to tax authorities.';
#if not CLEAN27
                Visible = IsNewFeatureEnabled;
                Enabled = IsNewFeatureEnabled;
#endif
            }
        }
        addfirst(Category_Report)
        {
            actionref("VAT Audit Report_Promoted_GB"; "VAT Audit Report GB")
            {
            }
            actionref("VAT Entry Exception Report_Promoted_GB"; "VAT Entry Exception Report GB")
            {
            }
        }
    }

#if not CLEAN27
    var
        IsNewFeatureEnabled: Boolean;
#endif

#if not CLEAN27
    trigger OnOpenPage()
    var
        VATAuditReportsGBFeature: Codeunit "VAT Audit GB";
    begin
        IsNewFeatureEnabled := VATAuditReportsGBFeature.IsEnabled();
    end;
#endif
}