// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.FixedAssets;

using Microsoft.FixedAssets.Journal;
using Microsoft.Sustainability.Setup;

pageextension 6294 "Sust. FA Reclass. Journal" extends "FA Reclass. Journal"
{
    layout
    {
        addafter("New FA No.")
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Sustainability Account No. field.';
            }
            field("New Sust. Account No."; Rec."New Sust. Account No.")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the New Sustainability Account No. field.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        VisibleSustainabilityControls();
    end;

    local procedure VisibleSustainabilityControls()
    begin
        SustainabilitySetup.GetRecordOnce();

        SustainabilityVisible := SustainabilitySetup."Enable Value Chain Tracking";
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityVisible: Boolean;
}