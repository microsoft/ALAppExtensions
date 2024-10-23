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
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies whether the item was received or shipped by the company.';
                }
                field(Date; Rec.Date)
                {
                    ToolTip = 'Specifies the date the item entry was posted.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number on the entry.';
                    ShowMandatory = true;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the number of the item.';
                }
                field(Name; Rec."Item Name")
                {
                    ToolTip = 'Specifies the name of the item.';
                    Caption = 'Item Name';
                }
                field("Tariff No."; Rec."Tariff No.")
                {
                    ToolTip = 'Specifies the item''s tariff number.';
                }
                field("Item Description"; Rec."Tariff Description")
                {
                    ToolTip = 'Specifies the name of the tariff no. that is associated with the item.';
                    Caption = 'Tariff No. Description';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region of the address.';
                }
                field("Partner VAT ID"; Rec."Partner VAT ID")
                {
                    ToolTip = 'Specifies the counter party''s VAT number.';
                }
                field("Country/Region of Origin Code"; Rec."Country/Region of Origin Code")
                {
                    ToolTip = 'Specifies a code for the country/region where the item was produced or processed.';
                }
                field("Area"; Rec.Area)
                {
                    ToolTip = 'Specifies the area of the customer or vendor, for the purpose of reporting to INTRASTAT.';
                    Visible = false;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ToolTip = 'Specifies the type of transaction that the document represents, for the purpose of reporting to INTRASTAT.';
                }
                field("Transaction Specification"; Rec."Transaction Specification")
                {
                    ToolTip = 'Specifies a specification of the document''s transaction, for the purpose of reporting to INTRASTAT.';
                    Visible = false;
                }
                field("Transport Method"; Rec."Transport Method")
                {
                    ToolTip = 'Specifies the transport method, for the purpose of reporting to INTRASTAT.';
                }
                field("Entry/Exit Point"; Rec."Entry/Exit Point")
                {
                    ToolTip = 'Specifies the code of either the port of entry where the items passed into your country/region or the port of exit.';
                    Visible = false;
                }
                field("Supplementary Units"; Rec."Supplementary Units")
                {
                    ToolTip = 'Specifies if you must report information about quantity and units of measure for this item.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the number of units of the item in the entry.';
                }
                field("Net Weight"; Rec."Net Weight")
                {
                    ToolTip = 'Specifies the net weight of one unit of the item.';
                }
                field("Total Weight"; Rec."Total Weight")
                {
                    ToolTip = 'Specifies the total weight for the items in the item entry.';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the total amount of the entry, excluding VAT.';
                }
                field("Statistical Value"; Rec."Statistical Value")
                {
                    ToolTip = 'Specifies the entry''s statistical value, which must be reported to the statistics authorities.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ToolTip = 'Specifies the entry type.';
                }
                field("Source Entry No."; Rec."Source Entry No.")
                {
                    ToolTip = 'Specifies the number that the item entry had in the table it came from.';
                    Editable = false;
                }
                field("Cost Regulation %"; Rec."Cost Regulation %")
                {
                    ToolTip = 'Specifies any indirect costs, as a percentage.';
                    Visible = false;
                }
                field("Indirect Cost"; Rec."Indirect Cost")
                {
                    ToolTip = 'Specifies an amount that represents the costs for freight and insurance.';
                    Visible = false;
                }
                field("Internal Ref. No."; Rec."Internal Ref. No.")
                {
                    ToolTip = 'Specifies a reference number used by the customs and tax authorities.';
                }
                field("Shpt. Method Code"; Rec."Shpt. Method Code")
                {
                    ToolTip = 'Specifies the item''s shipment method.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the code for the location that the entry is linked to.';
                }
                field("Suppl. Conversion Factor"; Rec."Suppl. Conversion Factor")
                {
                    ToolTip = 'Specifies the conversion factor of the item on this Intrastat report line.';
                }
                field("Suppl. Unit of Measure"; Rec."Suppl. Unit of Measure")
                {
                    ToolTip = 'Specifies the unit of measure code for the tariff number on this line.';
                }
                field("Supplementary Quantity"; Rec."Supplementary Quantity")
                {
                    ToolTip = 'Specifies the quantity of supplementary units on the Intrastat line.';
                }
            }
        }
    }
}