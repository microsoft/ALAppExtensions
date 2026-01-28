// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using System.Telemetry;

page 6785 "Wthldg. Tax Prod. Post. Group"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Withholding Tax Prod. Post. Group';
    PageType = List;
    SourceTable = "Wthldg. Tax Prod. Post. Group";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(GroupName)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code for the posting group.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description for the Withholding Tax Product posting group.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Setup")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Setup';
                Image = Setup;
                RunObject = Page "Withholding Tax Posting Setup";
                RunPageLink = "Wthldg. Tax Prod. Post. Group" = field(Code);
                ToolTip = 'View or edit the withholding tax posting setup information. This includes posting groups, revenue types, and accounts.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("&Setup_Promoted"; "&Setup")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        FeatureTelemetry.LogUptake('0000HH3', APACWHTTok, Enum::"Feature Uptake Status"::Discovered);
    end;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        APACWHTTok: Label 'APAC Set Up Withholding Tax', Locked = true;
}