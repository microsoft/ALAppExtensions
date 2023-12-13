// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

#if not CLEAN22
using System.Environment.Configuration;
#endif

page 31300 "Statistic Indications CZ"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Statistic Indications';
    PageType = List;
    SourceTable = "Statistic Indication CZ";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Tariff No."; Rec."Tariff No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for the item''s tariff number.';
                }
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the statistic indication code for the item.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description for statistic indication.';
                }
                field("Description EN"; Rec."Description EN")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the english description for statistic indication.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
#if not CLEAN22

    trigger OnOpenPage()
    var
        IntrastatReportMgt: Codeunit IntrastatReportManagement;
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        if not IntrastatReportMgt.IsFeatureEnabled() then begin
            IntrastatReportMgt.ShowNotEnabledMessage(CurrPage.Caption);
            if ApplicationAreaMgmt.IsBasicCountryEnabled('EU') then
#pragma warning disable AL0432
                Page.Run(Page::"Statistic Indications CZL")
#pragma warning restore AL0432
            else
                Page.Run(Page::"Feature Management");
            Error('');
        end;
    end;
#endif
}
