page 1943 "MigrationGP FiscalPeriodsTable"
{
    PageType = Card;
    SourceTable = "MigrationGP Fiscal Periods";
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
                field(PERIODID; PERIODID) { ApplicationArea = All; }
                field(YEAR1; YEAR1) { ApplicationArea = All; }
                field(PERIODDT; PERIODDT) { ApplicationArea = All; }
                field(PERDENDT; PERDENDT) { ApplicationArea = All; }
            }
        }
    }
}