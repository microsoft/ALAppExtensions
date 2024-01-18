// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

#if not CLEAN22
using System.Environment.Configuration;
#endif

page 31301 "Intrastat Delivery Groups CZ"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Intrastat Delivery Groups';
    PageType = List;
    SourceTable = "Intrastat Delivery Group CZ";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the intrastat delivery group.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the descpriton of intrastat delivery group.';
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
                Visible = true;
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
                Page.Run(Page::"Intrastat Delivery Groups CZL")
#pragma warning restore AL0432
            else
                Page.Run(Page::"Feature Management");
            Error('');
        end;
    end;
#endif
}