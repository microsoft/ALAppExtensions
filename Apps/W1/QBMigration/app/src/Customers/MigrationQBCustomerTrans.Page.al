#pragma warning disable AA0247
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
                field(TransType; Rec.TransType) { ApplicationArea = All; }
                field(DocNumber; Rec.DocNumber) { ApplicationArea = All; }
                field(GLDocNo; Rec.GLDocNo) { ApplicationArea = All; }
                field(TxnDate; Rec.TxnDate) { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
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
                    ToolTip = 'View QuickBooks posting accounts.';
                }
            }
        }
    }
}
