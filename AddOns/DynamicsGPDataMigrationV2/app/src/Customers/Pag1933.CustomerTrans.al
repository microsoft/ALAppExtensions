page 1933 "MigrationGP CustomerTrans"
{
    PageType = List;
    SourceTable = "MigrationGP CustomerTrans";
    Caption = 'Customer Transactions';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Id) { ApplicationArea = All; }
                field(CUSTNMBR; CUSTNMBR) { ApplicationArea = All; }
                field(DOCNUMBR; DOCNUMBR) { ApplicationArea = All; }
                field(DOCDATE; DOCDATE) { ApplicationArea = All; }
                field(DUEDATE; DUEDATE) { ApplicationArea = All; }
                field(CURTRXAM; CURTRXAM) { ApplicationArea = All; }
                field(RMDTYPAL; RMDTYPAL) { ApplicationArea = All; }
                field(GLDocNo; GLDocNo) { ApplicationArea = All; }
                field(TransType; TransType) { ApplicationArea = All; }
                field(SLPRSNID; SLPRSNID) { ApplicationArea = All; }
                field(PYMTRMID; PYMTRMID) { ApplicationArea = All; }
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