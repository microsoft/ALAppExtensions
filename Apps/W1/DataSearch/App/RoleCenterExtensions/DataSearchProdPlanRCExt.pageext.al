pageextension 2682 "Data Search Prod. Plan. RC Ext" extends "Production Planner Role Center"
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