namespace Microsoft.Sustainability.Certificate;

using Microsoft.Inventory.Item;
using Microsoft.Sustainability.Setup;

pageextension 6222 "Sust. Item Card" extends "Item Card"
{
    layout
    {
        addafter(Warehouse)
        {
            group("Sustainability")
            {
                Caption = 'Sustainability';
                Visible = SustainabilityVisible;

                field("GHG Credit"; Rec."GHG Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Greenhouse Gas Credit of the Item.';
                }
                field("Carbon Credit Per UOM"; Rec."Carbon Credit Per UOM")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = Rec."GHG Credit";
                    ToolTip = 'Specifies the Carbon Credit Per UOM of the Item.';
                }
                field("Sust. Cert. No."; Rec."Sust. Cert. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Sustainability Certificate Number of the Item.';
                }
                field("Sust. Cert. Name"; Rec."Sust. Cert. Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Sustainability Certificate Name of the Item.';
                }
                field("Default Sust. Account"; Rec."Default Sust. Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Default Sust. Account field.';
                }
                field("Default CO2 Emission"; Rec."Default CO2 Emission")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Replenishment System" = Rec."Replenishment System"::Purchase;
                    ToolTip = 'Specifies the value of the Default CO2 Emission field.';
                }
                field("Default CH4 Emission"; Rec."Default CH4 Emission")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Replenishment System" = Rec."Replenishment System"::Purchase;
                    ToolTip = 'Specifies the value of the Default CH4 Emission field.';
                }
                field("Default N2O Emission"; Rec."Default N2O Emission")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = Rec."Replenishment System" = Rec."Replenishment System"::Purchase;
                    ToolTip = 'Specifies the value of the Default N2O Emission field.';
                }
                field("CO2e per Unit"; Rec."CO2e per Unit")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the value of the CO2e per Unit field.';
                }
                field("Item Of Concern"; Rec."Item Of Concern")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Item Of Concern field.';
                }
            }
        }
    }

    actions
    {
        addafter(PrintLabel)
        {
            action("Calculate CO2e")
            {
                Caption = 'Calculate CO2e';
                ApplicationArea = Basic, Suite;
                Visible = SustainabilityVisible and not SustainabilityAllGasesAsCO2eVisible;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Calculate CO2e action.';

                trigger OnAction()
                begin
                    RunCalculateCO2e();
                end;
            }
            action("Calculate Total CO2e")
            {
                Caption = 'Calculate Total CO2e';
                ApplicationArea = Basic, Suite;
                Visible = SustainabilityVisible and SustainabilityAllGasesAsCO2eVisible;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Calculate Total CO2e action.';

                trigger OnAction()
                begin
                    RunCalculateCO2e();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        VisibleSustainabilityControls();
    end;

    local procedure VisibleSustainabilityControls()
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();

        SustainabilityVisible := SustainabilitySetup."Item Emissions";
        SustainabilityAllGasesAsCO2eVisible := SustainabilitySetup."Use All Gases As CO2e";
    end;

    local procedure RunCalculateCO2e()
    var
        Item: Record Item;
        CalculateCO2e: Report "Sust. Item Calculate CO2e";
    begin
        Item.SetFilter("No.", Rec."No.");
        CalculateCO2e.SetTableView(Item);
        CalculateCO2e.Run();
    end;

    var
        SustainabilityVisible: Boolean;
        SustainabilityAllGasesAsCO2eVisible: Boolean;
}