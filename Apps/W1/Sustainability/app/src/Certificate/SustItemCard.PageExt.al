namespace Microsoft.Sustainability.Certificate;

using Microsoft.Inventory.Item;
using Microsoft.Sustainability.Codes;
using Microsoft.Sustainability.EPR;
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
                field("Item of Concern"; Rec."Item of Concern")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Item of Concern field.';
                }
                field("Recyclability Percentage"; Rec."Recyclability Percentage")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Energy Efficiency Rating"; Rec."Energy Efficiency Rating")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("End-of-Life Information"; Rec."End-of-Life Information")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Source of Emission Data"; Rec."Source of Emission Data")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Source of Emission Data field.';
                }
                field("Emission Verified"; Rec."Emission Verified")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Emission Verified field.';
                }
                field("CBAM Compliance"; Rec."CBAM Compliance")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the CBAM Compliance field.';
                }
                field("EPR Category"; Rec."EPR Category")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the EPR Category field.';
                }
                field("Material Composition No."; Rec."Material Composition No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Material Composition No. field.';
                }
                field("Total EPR Weight"; Rec."Total EPR Weight")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Total EPR Weight field.';
                }
                field("EPR Fees Per Unit"; Rec."EPR Fees Per Unit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the EPR Fees per Unit field.';
                }
                field("End-of-Life Disposal Req."; Rec."End-of-Life Disposal Req.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the End-of-Life Disposal Requirements field.';
                }
                group("Product Classification")
                {
                    Caption = 'Product Classification';
                    field("Product Classification Type"; Rec."Product Classification Type")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Product Classification Code"; Rec."Product Classification Code")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                    field("Product Classification Name"; Rec."Product Classification Name")
                    {
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
        }

        addlast(factboxes)
        {
            part("Sust. Item Mat. Comp. Factbox"; "Sust. Item Mat. Comp. Factbox")
            {
                ApplicationArea = All;
                Caption = 'Material Composition';
                UpdatePropagation = Both;
                Visible = SustainabilityVisible;
                SubPageLink = "Item Material Composition No." = field("Material Composition No.");
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
        addlast(navigation)
        {
            action(ProductClassificationCodes)
            {
                Caption = 'Product Classification Codes';
                ApplicationArea = All;
                Image = ListPage;
                ToolTip = 'Opens the Product Classification Codes page.';
                RunPageMode = Edit;
                RunObject = page "Product Classification List";
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
        SustainabilitySetup.GetRecordOnce();

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