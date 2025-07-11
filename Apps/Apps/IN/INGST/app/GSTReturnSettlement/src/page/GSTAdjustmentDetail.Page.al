// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

page 18330 "GST Adjustment Detail"
{
    Caption = 'GST Adjustment Detail';
    Editable = false;
    PageType = List;
    SourceTable = "GST Adjustment Buffer";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of document that the entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number for the journal entry .';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s posting date.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of product that the entry belongs to.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unique identification number of the specified type.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies  if the Source Type of the Entry is Customer,Vendor,Bank or G/L Account.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source number as per defined type in source type.';
                }
                field("GST %"; Rec."GST %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST rate used in GST calculation in posted entry.';
                }
                field("GST Base Amount"; Rec."GST Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount that the GST amount is calculated from.';
                }
                field("GST Amount"; Rec."GST Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Displays the tax amount computed by applying GST percentage on GST base.';
                }
                field("GST Credit Type"; Rec."GST Credit Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST credit to be availment or Non-Availment.';
                }
                field("GST Component Code"; Rec."GST Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST component code with which the entry was posted.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity.';
                }
                field("Amount Loaded on Inventory"; Rec."Amount Loaded on Inventory")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount loaded on inventory.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code for which the entry was posted.';
                }
                field("Adjustment Type"; Rec."Adjustment Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the adjustment type';
                }
                field("Amount to be Adjusted"; Rec."Amount to be Adjusted")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount which will be adjusted.';
                }
            }
        }
    }
}

