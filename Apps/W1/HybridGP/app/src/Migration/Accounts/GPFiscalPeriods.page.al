#if not CLEAN26
namespace Microsoft.DataMigration.GP;

page 4092 "GP Fiscal Periods"
{
    PageType = Card;
    SourceTable = "GP Fiscal Periods";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Fiscal Periods Table';
    PromotedActionCategories = 'Related Entities';
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteReason = 'Removing the GP staging table pages because they cause confusion and should not be used.';
    ObsoleteTag = '26.0';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(PERIODID; Rec.PERIODID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Period Id';
                }
                field(YEAR1; Rec.YEAR1)
                {
                    ApplicationArea = All;
                    ToolTip = 'Year 1';
                }
                field(PERIODDT; Rec.PERIODDT)
                {
                    ApplicationArea = All;
                    ToolTip = 'PERIODDT';
                }
                field(PERDENDT; Rec.PERDENDT)
                {
                    ApplicationArea = All;
                    ToolTip = 'PERDENDT';
                }
            }
        }
    }
}
#endif