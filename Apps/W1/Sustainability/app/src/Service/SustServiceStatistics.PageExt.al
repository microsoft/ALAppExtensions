// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Service;

using Microsoft.Service.Document;

pageextension 6307 "Sust. Service Statistics" extends "Service Statistics"
{
    layout
    {
        addafter(Customer)
        {
            group(Sustainability)
            {
                Visible = EnableSustainability;
                Caption = 'Sustainability';
                field("Total CO2e"; Rec."Total CO2e")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total CO2e';
                    ToolTip = 'Specifies the total CO2e emissions.';
                }
                field("Posted Total CO2e"; Rec."Posted Total CO2e")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Total CO2e';
                    ToolTip = 'Specifies the posted total CO2e emissions.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        EnableSustainabilityControl();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        EnableSustainabilityControl();
    end;

    trigger OnAfterGetRecord()
    begin
        EnableSustainabilityControl();
    end;

    local procedure EnableSustainabilityControl()
    begin
        Rec.CalcFields("Sustainability Lines Exist");
        EnableSustainability := Rec."Sustainability Lines Exist";
    end;

    var
        EnableSustainability: Boolean;
}