pageextension 2687 "Data Search Whse. Bas. RC Ext" extends "Whse. Basic Role Center"
{
    actions
    {
        addafter(PlanningWorksheets)
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