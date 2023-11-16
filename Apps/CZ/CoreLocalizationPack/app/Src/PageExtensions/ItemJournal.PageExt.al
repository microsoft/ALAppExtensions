// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Journal;

pageextension 11711 "Item Journal CZL" extends "Item Journal"
{
    layout
    {
        addafter("Transport Method")
        {
            field("Transaction Specification CZL"; Rec."Transaction Specification")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the transaction specification, for the purpose of reporting to INTRASTAT.';
            }
            field("Shpt. Method Code CZL"; Rec."Shpt. Method Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the item''s shipment method.';
                Visible = false;
            }
        }
        addafter("Document Date")
        {
            field("Invt. Movement Template CZL"; InvtMovementTemplateNameCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Inventory Movement Template';
                ToolTip = 'Specifies the template for item movement.';
                TableRelation = "Invt. Movement Template CZL" where("Entry Type" = filter(Purchase .. "Negative Adjmt."));

                trigger OnValidate()
                begin
                    Rec.Validate("Invt. Movement Template CZL", InvtMovementTemplateNameCZL);
                    EntryType := Rec."Entry Type";
                end;
            }
        }
        addafter("Gen. Prod. Posting Group")
        {
            field("G/L Correction CZL"; Rec."G/L Correction CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to include general ledger corrections on the item journal line.';
                Visible = false;
            }
        }
#if not CLEAN22
        addafter("Unit Cost")
        {
            field("Net Weight CZL"; Rec."Net Weight CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Net Weight (Obsolete)';
                ToolTip = 'Specifies the net weight of the item.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
            }
        }
        addafter("Applies-from Entry")
        {
            field("Intrastat Transaction CZL"; Rec."Intrastat Transaction CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Transaction (Obsolete)';
                ToolTip = 'Specifies if the entry an Intrastat transaction is.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
            }
        }
        addbefore("Shortcut Dimension 1 Code")
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Tariff No. (Obsolete)';
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
            }
        }
        addafter("Country/Region Code")
        {
            field("Country/Reg. of Orig. Code CZL"; Rec."Country/Reg. of Orig. Code CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Country/Region of Origin Code (Obsolete)';
                ToolTip = 'Specifies the origin country/region code.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
            }
        }
        addlast(Control1)
        {
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Statistic Indication (Obsolete)';
                ToolTip = 'Specifies the statistic indication code.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
            field("Physical Transfer CZL"; Rec."Physical Transfer CZL")
            {
                ApplicationArea = SalesReturnOrder;
                Caption = 'Physical Transfer (Obsolete)';
                ToolTip = 'Specifies if there is physical transfer of the item.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
        }
#endif
    }

    trigger OnAfterGetCurrRecord()
    begin
        InvtMovementTemplateNameCZL := Rec."Invt. Movement Template CZL";
    end;

    trigger OnAfterGetRecord()
    begin
        InvtMovementTemplateNameCZL := Rec."Invt. Movement Template CZL";
    end;

    var
        InvtMovementTemplateNameCZL: Code[10];
}
