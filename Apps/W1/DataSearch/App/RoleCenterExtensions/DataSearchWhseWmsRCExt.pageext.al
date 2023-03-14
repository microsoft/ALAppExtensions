pageextension 2688 "Data Search Whse. Wms. RC Ext" extends"Whse. WMS Role Center"
{
    actions
    {
        addafter("M&ovement Worksheet")
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