pageextension 2683 "Data Search Bus. Man. RC Ext" extends "Business Manager Role Center"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by direct access from the Tell Me search.';
    ObsoleteTag = '23.0';
    actions
    {
        addafter(Navigate)
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