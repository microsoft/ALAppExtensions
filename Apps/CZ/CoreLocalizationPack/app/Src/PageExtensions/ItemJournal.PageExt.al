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
        addafter("Unit Cost")
        {
            field("Net Weight CZL"; Rec."Net Weight CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the net weight of the item.';
                Visible = false;
            }
        }
        addafter("Applies-from Entry")
        {
            field("Intrastat Transaction CZL"; Rec."Intrastat Transaction CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the entry an Intrastat transaction is.';
                Visible = false;
            }
        }
        addbefore("Shortcut Dimension 1 Code")
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
        }
        addafter("Country/Region Code")
        {
            field("Country/Reg. of Orig. Code CZL"; Rec."Country/Reg. of Orig. Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the origin country/region code.';
                Visible = false;
            }
        }
        addlast(Control1)
        {
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the statistic indication code.';
                Visible = false;
            }
            field("Physical Transfer CZL"; Rec."Physical Transfer CZL")
            {
                ApplicationArea = SalesReturnOrder;
                ToolTip = 'Specifies if there is physical transfer of the item.';
                Visible = false;
            }
        }
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
