pageextension 2686 "Data Search Rel. Man. RC Ext" extends "Sales & Relationship Mgr. RC"
{
    actions
    {
        addafter("Navi&gate")
        {
            action(DataSearch)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Search in data';
                Ellipsis = true;
                Image = Find;
                RunObject = Page "Data Search";
                ShortCutKey = 'Ctrl+Alt+F';
                ToolTip = 'Search across a predefined set of tables for this role.';
            }
        }
    }
}