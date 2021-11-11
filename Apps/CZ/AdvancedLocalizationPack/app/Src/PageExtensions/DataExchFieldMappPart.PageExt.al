pageextension 31243 "Data Exch Field Mapp. Part CZA" extends "Data Exch Field Mapping Part"
{
    layout
    {
        addlast(Group)
        {
            field("Date Formula_CZA"; Rec."Date Formula CZA")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Date formula for calculating the resulting date';
            }
        }
    }
}