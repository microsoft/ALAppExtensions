// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

page 4816 "Intrastat Report Lines"
{
    ApplicationArea = All;
    Caption = 'Intrastat Report Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Intrastat Report Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type; Rec.Type) { }
                field(Date; Rec.Date) { }
                field("Document No."; Rec."Document No.")
                {
                    ShowMandatory = true;
                }
                field("Item No."; Rec."Item No.") { }
                field(Name; Rec."Item Name") { }
                field("Tariff No."; Rec."Tariff No.") { }
                field("Item Description"; Rec."Tariff Description") { }
                field("Country/Region Code"; Rec."Country/Region Code") { }
                field("Partner VAT ID"; Rec."Partner VAT ID") { }
                field("Country/Region of Origin Code"; Rec."Country/Region of Origin Code") { }
                field("Area"; Rec.Area)
                {
                    Visible = false;
                }
                field("Transaction Type"; Rec."Transaction Type") { }
                field("Transaction Specification"; Rec."Transaction Specification")
                {
                    Visible = false;
                }
                field("Transport Method"; Rec."Transport Method") { }
                field("Entry/Exit Point"; Rec."Entry/Exit Point")
                {
                    Visible = false;
                }
                field("Supplementary Units"; Rec."Supplementary Units") { }
                field(Quantity; Rec.Quantity) { }
                field("Net Weight"; Rec."Net Weight") { }
                field("Total Weight"; Rec."Total Weight") { }
                field(Amount; Rec.Amount) { }
                field("Statistical Value"; Rec."Statistical Value") { }
                field("Source Type"; Rec."Source Type") { }
                field("Source Entry No."; Rec."Source Entry No.")
                {
                    Editable = false;
                }
                field("Cost Regulation %"; Rec."Cost Regulation %")
                {
                    Visible = false;
                }
                field("Indirect Cost"; Rec."Indirect Cost")
                {
                    Visible = false;
                }
                field("Internal Ref. No."; Rec."Internal Ref. No.") { }
                field("Shpt. Method Code"; Rec."Shpt. Method Code") { }
                field("Location Code"; Rec."Location Code") { }
                field("Suppl. Conversion Factor"; Rec."Suppl. Conversion Factor") { }
                field("Suppl. Unit of Measure"; Rec."Suppl. Unit of Measure") { }
                field("Supplementary Quantity"; Rec."Supplementary Quantity") { }
            }
        }
    }
}