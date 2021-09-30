pageextension 31129 "Transfer Order Subform CZL" extends "Transfer Order Subform"
{
    layout
    {
        addafter("Reserved Quantity Outbnd.")
        {
            field("Country/Reg. of Orig. Code CZL"; Rec."Country/Reg. of Orig. Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the origin country/region code.';
                Visible = false;
            }            
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the statistic indication code.';
                Visible = false;
            }
            field("Net Weight CZL"; Rec."Net Weight")
            {
                ApplicationArea = Location;
                ToolTip = 'Specifies the net weight of the item.';
                Visible = false;
            }
        }
    }
}