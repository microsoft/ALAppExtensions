// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Purchase;

using Microsoft.Purchases.Document;
using Microsoft.Sustainability.Setup;

pageextension 6280 "Sust. Item Charge Assign Purch" extends "Item Charge Assignment (Purch)"
{
    layout
    {
        addafter("Amount to Handle")
        {
            field("CO2e to Assign"; Rec."CO2e to Assign")
            {
                ApplicationArea = ItemCharges;
                Visible = SustainabilityVisible;
                ToolTip = 'Specifies the CO2e of the item charge that is going to be assigned to the document line.';
            }
            field("CO2e to Handle"; Rec."CO2e to Handle")
            {
                ApplicationArea = ItemCharges;
                Visible = SustainabilityVisible;
                Editable = false;
                ToolTip = 'Specifies the CO2e of the item charge that will be actually assigned to the document line.';
            }
        }
        addafter(AssgntAmount)
        {
            field(AssgntCO2e; AssgntCO2e)
            {
                ApplicationArea = ItemCharges;
                Caption = 'Total (CO2e)';
                AutoFormatType = 11;
                Visible = SustainabilityVisible;
                AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
                Editable = false;
                ToolTip = 'Specifies the total CO2e of the item charge that you can assign to the related document line.';
            }
        }
        addafter(TotalAmountToAssign)
        {
            field(TotalCO2eToAssign; TotalCO2eToAssign)
            {
                ApplicationArea = ItemCharges;
                Caption = 'CO2e to Assign';
                AutoFormatType = 11;
                Visible = SustainabilityVisible;
                AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
                Editable = false;
                ToolTip = 'Specifies the total CO2e of the item charge that you can assign to the related document line.';
            }
        }
        addafter(RemAmountToAssign)
        {
            field(RemCO2eToAssign; RemCO2eToAssign)
            {
                ApplicationArea = ItemCharges;
                Caption = 'Remaining CO2e to Assign';
                AutoFormatType = 11;
                Style = Unfavorable;
                StyleExpr = RemCO2eToAssign <> 0;
                Visible = SustainabilityVisible;
                AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
                Editable = false;
                ToolTip = 'Specifies the value of the quantity of the item charge that has not yet been assigned.';
            }
        }
        addafter(TotalAmountToHandle)
        {
            field(TotalCO2eToHandle; TotalCO2eToHandle)
            {
                ApplicationArea = ItemCharges;
                Caption = 'CO2e to Handle';
                AutoFormatType = 11;
                Visible = SustainabilityVisible;
                AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
                Editable = false;
                ToolTip = 'Specifies the total CO2e of the item charge that you can assign to the related document line.';
            }
        }
        addafter(RemAmountToHandle)
        {
            field(RemCO2eToHandle; RemCO2eToHandle)
            {
                ApplicationArea = ItemCharges;
                Caption = 'Remaining CO2e to Handle';
                AutoFormatType = 11;
                Style = Unfavorable;
                Visible = SustainabilityVisible;
                StyleExpr = RemCO2eToHandle <> 0;
                AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
                Editable = false;
                ToolTip = 'Specifies the value of the quantity of the item charge that has not yet been assigned.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        VisibleSustainabilityControls();
        PurchaseSubscriber.GetCO2eEmissionFromPurchLine(PurchLine2, AssgntCO2e);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateQtyAssgnt();
    end;

    local procedure VisibleSustainabilityControls()
    begin
        SustainabilitySetup.Get();

        SustainabilityVisible := SustainabilitySetup."Use Emissions In Purch. Doc.";
    end;

    local procedure UpdateQtyAssgnt()
    var
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
    begin
        ItemChargeAssgntPurch.Reset();
        ItemChargeAssgntPurch.SetCurrentKey("Document Type", "Document No.", "Document Line No.");
        ItemChargeAssgntPurch.SetRange("Document Type", Rec."Document Type");
        ItemChargeAssgntPurch.SetRange("Document No.", Rec."Document No.");
        ItemChargeAssgntPurch.SetRange("Document Line No.", Rec."Document Line No.");
        ItemChargeAssgntPurch.CalcSums("CO2e to Assign", "CO2e to Handle");

        TotalCO2eToAssign := ItemChargeAssgntPurch."CO2e to Assign";
        TotalCO2eToHandle := ItemChargeAssgntPurch."CO2e to Handle";

        RemCO2eToAssign := AssgntCO2e - TotalCO2eToAssign;
        RemCO2eToHandle := AssgntCO2e - TotalCO2eToHandle;
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        PurchaseSubscriber: Codeunit "Sust. Purchase Subscriber";
        SustainabilityVisible: Boolean;
        AssgntCO2e, TotalCO2eToAssign, RemCO2eToAssign, TotalCO2eToHandle, RemCO2eToHandle : Decimal;
}