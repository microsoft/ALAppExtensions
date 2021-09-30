pageextension 31289 "General Ledger Setup CZB" extends "General Ledger Setup"
{
    actions
    {
        addlast("Bank Posting")
        {
            action(SearchRules)
            {
                Caption = 'Search Rules';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Set up rules for automatically matching payments on bank statements.';
                Image = ViewRegisteredOrder;
                RunObject = page "Search Rule List CZB";
                RunPageMode = Edit;
            }
        }
    }
}
