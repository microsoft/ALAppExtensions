#if not CLEAN26
namespace Microsoft.DataMigration.GP;

page 4091 "GP GLTransactions"
{
    PageType = List;
    SourceTable = "GP GLTransactions";
    Caption = 'General Ledger Transactions';
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
                field(ACTINDX; Rec.ACTINDX)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Index';
                }
                field(YEAR1; Rec.YEAR1)
                {
                    ApplicationArea = All;
                    ToolTip = 'Year';
                }
                field(PERIODID; Rec.PERIODID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Period ID';
                }
                field(DEBITAMT; Rec.DEBITAMT)
                {
                    ApplicationArea = All;
                    ToolTip = 'Debit Amount';
                }
                field(CRDTAMNT; Rec.CRDTAMNT)
                {
                    ApplicationArea = All;
                    ToolTip = 'Credit Amount';
                }
                field(PERDBLNC; Rec.PERDBLNC)
                {
                    ApplicationArea = All;
                    ToolTip = 'PERDBLNC';
                }
                field(MNACSGMT; Rec.MNACSGMT)
                {
                    ApplicationArea = All;
                    ToolTip = 'Main account segment';
                }
                field(ACTNUMBR_1; Rec.ACTNUMBR_1)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Segment 1';
                }
                field(ACTNUMBR_2; Rec.ACTNUMBR_2)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Segment 2';
                }
                field(ACTNUMBR_3; Rec.ACTNUMBR_3)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Segment 3';
                }
                field(ACTNUMBR_4; Rec.ACTNUMBR_4)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Segment 4';
                }
                field(ACTNUMBR_5; Rec.ACTNUMBR_5)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Segment 5';
                }
                field(ACTNUMBR_6; Rec.ACTNUMBR_6)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Segment 6';
                }
                field(ACTNUMBR_7; Rec.ACTNUMBR_7)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Segment 7';
                }
                field(ACTNUMBR_8; Rec.ACTNUMBR_8)
                {
                    ApplicationArea = All;
                    ToolTip = 'Account Segment 8';
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