pageextension 11714 "Job Journal CZL" extends "Job Journal"
{
    layout
    {
        addafter("Document Date")
        {
            field("Invt. Movement Template CZL"; Rec."Invt. Movement Template CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the template for item movement.';
            }
        }
        addafter("Total Price (LCY)")
        {
            field("Net Weight CZL"; Rec."Net Weight CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the net weight of the item.';
                Visible = false;
            }
        }
        addafter("Country/Region Code")
        {
            field("Intrastat Transaction CZL"; Rec."Intrastat Transaction CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the entry an Intrastat transaction is.';
                Visible = false;
            }
        }
        addafter("Transport Method")
        {
            field("Transaction Specification CZL"; Rec."Transaction Specification")
            {
                ApplicationArea = Jobs;
                ToolTip = 'Specifies a code for the transaction specification, for the purpose of reporting to INTRASTAT.';
                Visible = false;
            }
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
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
        }
    }
}
