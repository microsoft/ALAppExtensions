// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

pageextension 12217 "Service Decl. Subform IT" extends "Service Declaration Subform"
{
    layout
    {
        modify("Posting Date")
        {
            Visible = false;
        }
        modify("Document Type")
        {
            Visible = false;
        }
        modify("Item Charge No.")
        {
            Visible = false;
        }
        modify("Service Transaction Code")
        {
            Visible = false;
        }
        modify("VAT Reg. No.")
        {
            Visible = true;
        }
        modify("Sales Amount (LCY)")
        {
            Visible = false;
        }
        modify("Purchase Amount (LCY)")
        {
            Visible = false;
        }
        addafter("Posting Date")
        {
            field("Document Date"; Rec."Document Date")
            {
                Caption = 'Date';
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the document date.';
            }
            field("Reference Period"; Rec."Reference Period")
            {
                ApplicationArea = BasicEU;
                Editable = false;
                ToolTip = 'Specifies the reference period.';
            }
        }
        addafter("Document No.")
        {
            field("External Document No."; Rec."External Document No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the external document number.';
            }
        }
        addafter("VAT Reg. No.")
        {
            field("Service Tariff No."; Rec."Service Tariff No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the ID of the service tariff that is associated with the Service Declaration.';
            }
            field("Transport Method"; Rec."Transport Method")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the transport method for the item entry.';
            }
            field("Payment Method"; Rec."Payment Method")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the payment method that is associated with the Service Declaration.';
            }
            field("Country/Region of Payment Code"; Rec."Country/Region of Payment Code")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the country/region of the payment method that is associated with the Service Declaration.';
            }
        }
        addafter("Currency Code")
        {
            field("Source Currency Amount"; Rec."Source Currency Amount")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the amount in the currency of the source of the transaction.';
            }
            field(Amount; Rec.Amount)
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the total amount of the entry, excluding VAT.';
            }
            field("Source Entry No."; Rec."Source Entry No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the source VAT Entry number.';
            }
            field("Custom Office No."; Rec."Custom Office No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the customs office that the trade of services passes through.';
            }
            field("Corrected Service Declaration No."; Rec."Corrected Service Declaration No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the number of the corrected Service Declaration report that is associated with the Service Declaraion.';
            }
            field("Corrected Document No."; Rec."Corrected Document No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the document number of the corrected Service Declaration entry.';
            }
            field("Progressive No."; Rec."Progressive No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the progressive number.';
            }
            field("Ref. File Disk No."; Rec."Ref. File Disk No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the corrected file reference number.';
            }
        }
    }
}
