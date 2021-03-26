pageextension 31099 "Item Ledger Entries CZL" extends "Item Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Statistic indication for Intrastat reporting purposes.';
                Visible = false;                
            }
            field("Physical Transfer CZL"; Rec."Physical Transfer CZL")
            {
                ApplicationArea = SalesReturnOrder;
                ToolTip = 'Specifies if there is physical transfer of the item.';
                Visible = false;
            }            
            field("Net Weight CZL"; Rec."Net Weight CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the net weight of the item.';
                Visible = false;
            }
            field("Country/Reg. of Orig. Code CZL"; Rec."Country/Reg. of Orig. Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the origin country/region code.';
                Visible = false;
            }
            field("Intrastat Transaction CZL"; Rec."Intrastat Transaction CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the entry an Intrastat transaction is.';
                Visible = false;
            }            
        }
    }
}