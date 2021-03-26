page 4092 "GP Fiscal Periods"
{
    PageType = Card;
    SourceTable = "GP Fiscal Periods";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Fiscal Periods Table';
    PromotedActionCategories = 'Related Entities';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(PERIODID; PERIODID) { ApplicationArea = All; ToolTip = 'Period Id'; }
                field(YEAR1; YEAR1) { ApplicationArea = All; ToolTip = 'Year 1'; }
                field(PERIODDT; PERIODDT) { ApplicationArea = All; ToolTip = 'PERIODDT'; }
                field(PERDENDT; PERDENDT) { ApplicationArea = All; ToolTip = 'PERDENDT'; }
            }
        }
    }
}