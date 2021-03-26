page 4091 "GP GLTransactions"
{
    PageType = List;
    SourceTable = "GP GLTransactions";
    Caption = 'General Ledger Transactions';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ACTINDX; ACTINDX) { ApplicationArea = All; ToolTip = 'Account Index'; }
                field(YEAR1; YEAR1) { ApplicationArea = All; ToolTip = 'Year'; }
                field(PERIODID; PERIODID) { ApplicationArea = All; ToolTip = 'Period ID'; }
                field(DEBITAMT; DEBITAMT) { ApplicationArea = All; ToolTip = 'Debit Amount'; }
                field(CRDTAMNT; CRDTAMNT) { ApplicationArea = All; ToolTip = 'Credit Amount'; }
                field(PERDBLNC; PERDBLNC) { ApplicationArea = All; ToolTip = 'PERDBLNC'; }
                field(MNACSGMT; MNACSGMT) { ApplicationArea = All; ToolTip = 'Main account segment'; }
                field(ACTNUMBR_1; ACTNUMBR_1) { ApplicationArea = All; ToolTip = 'Account Segment 1'; }
                field(ACTNUMBR_2; ACTNUMBR_2) { ApplicationArea = All; ToolTip = 'Account Segment 2'; }
                field(ACTNUMBR_3; ACTNUMBR_3) { ApplicationArea = All; ToolTip = 'Account Segment 3'; }
                field(ACTNUMBR_4; ACTNUMBR_4) { ApplicationArea = All; ToolTip = 'Account Segment 4'; }
                field(ACTNUMBR_5; ACTNUMBR_5) { ApplicationArea = All; ToolTip = 'Account Segment 5'; }
                field(ACTNUMBR_6; ACTNUMBR_6) { ApplicationArea = All; ToolTip = 'Account Segment 6'; }
                field(ACTNUMBR_7; ACTNUMBR_7) { ApplicationArea = All; ToolTip = 'Account Segment 7'; }
                field(ACTNUMBR_8; ACTNUMBR_8) { ApplicationArea = All; ToolTip = 'Account Segment 8'; }
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