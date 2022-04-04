page 1913 "MigrationQB CustomerTrans"
{
    PageType = List;
    SourceTable = "MigrationQB CustomerTrans";
    Caption = 'Customer Transactions';

    layout
    {
        area(content)
        {
            repeater(General)
            {
#pragma warning disable AA0218
                field(TransType; TransType) { ApplicationArea = All; }
                field(DocNumber; DocNumber) { ApplicationArea = All; }
                field(GLDocNo; GLDocNo) { ApplicationArea = All; }
                field(TxnDate; TxnDate) { ApplicationArea = All; }
                field(Amount; Amount) { ApplicationArea = All; }
#pragma warning restore

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
                    RunObject = Page "MigrationQB Posting Accounts";
                    RunPageMode = Edit;
                }
            }
        }
    }
}