#if not CLEAN26
namespace Microsoft.DataMigration.GP;

page 4094 "GP Customer Transactions"
{
    Caption = 'GP Customer Transactions';
    PageType = List;
    SourceTable = "GP Customer Transactions";
    ApplicationArea = All;
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteReason = 'Removing the GP staging table pages because they cause confusion and should not be used.';
    ObsoleteTag = '26.0';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Id';
                }
                field(CUSTNMBR; Rec.CUSTNMBR)
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer Number';
                }
                field(DOCNUMBR; Rec.DOCNUMBR)
                {
                    ApplicationArea = All;
                    ToolTip = 'Document Number';
                }
                field(DOCDATE; Rec.DOCDATE)
                {
                    ApplicationArea = All;
                    ToolTip = 'Document Date';
                }
                field(DUEDATE; Rec.DUEDATE)
                {
                    ApplicationArea = All;
                    ToolTip = 'Due Date';
                }
                field(CURTRXAM; Rec.CURTRXAM)
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer Transaction Amount';
                }
                field(RMDTYPAL; Rec.RMDTYPAL)
                {
                    ApplicationArea = All;
                    ToolTip = 'RMDTYPAL';
                }
                field(GLDocNo; Rec.GLDocNo)
                {
                    ApplicationArea = All;
                    ToolTip = 'GL Document Number';
                }
                field(TransType; Rec.TransType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Transaction Type';
                }
                field(SLPRSNID; Rec.SLPRSNID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Salesperson Id';
                }
                field(PYMTRMID; Rec.PYMTRMID)
                {
                    ApplicationArea = All;
                    ToolTip = 'PYMTRMID';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(SupportingPages)
            {
                Caption = 'Supporting Pages';

                action(AccountSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Posting Accounts';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = EntriesList;
                    RunObject = Page "GP Posting Accounts";
                    RunPageMode = Edit;
                    ToolTip = 'Posting Account Setup';
                }
            }
        }
    }
}
#endif