// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using System.Telemetry;

page 4852 "Automatic Account List"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Automatic Account Groups';
    CardPageID = "Automatic Account Header";
    Editable = false;
    PageType = List;
    SourceTable = "Automatic Account Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1070002)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the automatic account group number in this field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an appropriate description of the automatic account group in this field.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0001P9L', AccTok, Enum::"Feature Uptake Status"::Discovered);
    end;

    var
        AccTok: Label 'W1 Automatic Account', Locked = true;
}

