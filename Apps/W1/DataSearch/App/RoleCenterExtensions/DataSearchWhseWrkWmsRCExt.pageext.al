pageextension 2689 "Data Search Whse WrkWms RC Ext" extends "Whse. Worker WMS Role Center"
{
    actions
    {
        addafter("Customer &Labels")
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