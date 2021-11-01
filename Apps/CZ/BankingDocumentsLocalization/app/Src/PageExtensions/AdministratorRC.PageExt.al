pageextension 31290 "Administrator RC CZB" extends "Administrator Main Role Center"
{
    actions
    {
        addafter("Bank Export/Import Setup")
        {
            action("Search Rules CZB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Search Rules';
                RunObject = page "Search Rule List CZB";
            }
        }
    }
}
