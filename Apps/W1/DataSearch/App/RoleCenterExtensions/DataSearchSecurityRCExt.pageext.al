pageextension 2690 "Data Search Security RC Ext" extends "Security Admin Role Center"
{
    actions
    {
#if not CLEAN21
        // the 'processing' area is being deprecated in this page. After that has been done, we can remove these pragmas without any other change        
#pragma warning disable AL0432
#endif
        addlast(processing)
#if not CLEAN21
#pragma warning restore AL0432
#endif
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