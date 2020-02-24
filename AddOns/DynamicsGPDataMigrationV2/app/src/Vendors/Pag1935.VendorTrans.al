page 1935 "MigrationGP VendorTrans"
{
    PageType = List;
    SourceTable = "MigrationGP VendorTrans";
    Caption = 'Vendor Transactions';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Id) { ApplicationArea = All; }
                field(VENDORID; VENDORID) { ApplicationArea = All; }
                field(DOCNUMBR; DOCNUMBR) { ApplicationArea = All; }
                field(DOCDATE; DOCDATE) { ApplicationArea = All; }
                field(DUEDATE; DUEDATE) { ApplicationArea = All; }
                field(CURTRXAM; CURTRXAM) { ApplicationArea = All; }
                field(DOCTYPE; DOCTYPE) { ApplicationArea = All; }
                field(GLDocNo; GLDocNo) { ApplicationArea = All; }
                field(TransType; TransType) { ApplicationArea = All; }
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