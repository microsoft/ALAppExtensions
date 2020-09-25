page 1939 "MigrationGP GLTrans"
{
    PageType = List;
    SourceTable = "MigrationGP GLTrans";
    Caption = 'General Ledger Transactions';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ACTINDX; ACTINDX) { ApplicationArea = All; }
                field(GLDocNo; GLDocNo) { ApplicationArea = All; }
                field(YEAR1; YEAR1) { ApplicationArea = All; }
                field(PERIODID; PERIODID) { ApplicationArea = All; }
                field(DEBITAMT; DEBITAMT) { ApplicationArea = All; }
                field(CRDTAMNT; CRDTAMNT) { ApplicationArea = All; }
                field(PERDBLNC; PERDBLNC) { ApplicationArea = All; }
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
                    RunObject = Page "MigrationGP Posting Accounts";
                    RunPageMode = Edit;
                }
            }
        }
    }
}