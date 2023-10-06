pageextension 2690 "Data Search Security RC Ext" extends "Security Admin Role Center"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by direct access from the Tell Me search.';
    ObsoleteTag = '23.0';
    actions
    {
        addlast("App Management")
        {
            action(DataSearch)
            {
                Visible = false;
                Enabled = false;
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