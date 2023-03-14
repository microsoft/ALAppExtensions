pageextension 2691 "Data Search Team Mbr. RC Ext" extends "Team Member Role Center"
{
    actions
    {
        addlast(Processing)
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