pageextension 31128 "Transfer Order CZL" extends "Transfer Order"
{
    layout
    {
        addfirst("Foreign Trade")
        {
            field(IsIntrastatTransactionCZL; Rec.IsIntrastatTransactionCZL())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Transaction';
                Editable = false;
                ToolTip = 'Specifies if the entry is an Intrastat transaction.';
            }
        }       
        addlast("Foreign Trade")
        {
            field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
            }
        }
    }
}