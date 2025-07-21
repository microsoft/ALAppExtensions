// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Job;

using Microsoft.Projects.Project.Job;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Setup;

pageextension 6287 "Sust. Job List" extends "Job List"
{
    actions
    {
        addafter("Ledger E&ntries")
        {
            action("Sustainability Value Entries")
            {
                ApplicationArea = Jobs;
                Caption = 'Sustainability Value Entries';
                Visible = SustainabilityVisible;
                Image = ValueLedger;
                RunObject = Page "Sustainability Value Entries";
                RunPageLink = "Job No." = field("No.");
                ToolTip = 'View the sustainability Value entries on the document or journal line.';
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