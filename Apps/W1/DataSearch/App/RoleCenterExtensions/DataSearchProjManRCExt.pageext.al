pageextension 2685 "Data Search Proj. Man. RC Ext" extends "Project Manager Role Center"
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