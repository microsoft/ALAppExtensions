#pragma warning disable AA0247
page 1915 "MigrationQB VendorTrans"
{
    PageType = List;
    SourceTable = "MigrationQB VendorTrans";
    Caption = 'Vendor Transactions';

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
                    ToolTip = 'View QuickBooks posting accounts.';
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
