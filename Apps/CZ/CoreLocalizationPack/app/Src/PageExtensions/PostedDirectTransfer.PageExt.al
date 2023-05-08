pageextension 31224 "Posted Direct Transfer CZL" extends "Posted Direct Transfer"
{
    layout
    {
        addafter("Transfer-from")
        {
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';

                field(IsIntrastatTransactionCZL; Rec.IsIntrastatTransactionCZL())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Intrastat Transaction';
                    Editable = false;
                    ToolTip = 'Specifies if the entry is an Intrastat transaction.';
                }
                field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies that entry will be excluded from intrastat.';
                }
            }
        }
    }
}