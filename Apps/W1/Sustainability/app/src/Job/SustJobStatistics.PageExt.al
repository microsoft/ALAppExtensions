// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Job;

using Microsoft.Projects.Project.Job;
using Microsoft.Sustainability.Setup;

pageextension 6285 "Sust. Job Statistics" extends "Job Statistics"
{
    layout
    {
        addafter("Job Planning Lines")
        {
            group(Sustainability)
            {
                Visible = EnableSustainability;
                Caption = 'Sustainability';
                fixed(FixedSustainability)
                {
                    ShowCaption = false;
                    group("Sustainability Resource")
                    {
                        Caption = 'Resource';
                        field("Resource (Total CO2e)"; Rec."Resource (Total CO2e)")
                        {
                            Caption = 'Total CO2e';
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies the value of the Resource (Total CO2e) field.';
                        }
                    }
                    group("Sustainability Item")
                    {
                        Caption = 'Item';
                        field("Item (Total CO2e)"; Rec."Item (Total CO2e)")
                        {
                            Caption = 'Total CO2e';
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies the value of the Item (Total CO2e) field.';
                        }
                    }
                    group("Sustainability G/L Account")
                    {
                        Caption = 'G/L Account';
                        field("G/L Account (Total CO2e)"; Rec."G/L Account (Total CO2e)")
                        {
                            Caption = 'Total CO2e';
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies the value of the G/L Account (Total CO2e) field.';
                        }
                    }
                    group("Sustainability Total")
                    {
                        Caption = 'Total';
                        field("Total CO2e"; Rec."Total CO2e")
                        {
                            Caption = 'Total CO2e';
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies the value of the Total CO2e field.';
                        }
                    }
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
        SustainabilitySetup.GetRecordOnce();

        EnableSustainability := SustainabilitySetup."Enable Value Chain Tracking";
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        EnableSustainability: Boolean;
}