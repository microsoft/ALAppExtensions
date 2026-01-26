#pragma warning disable AA0247
page 1912 "MigrationQB CustomerTable"
{
    PageType = Card;
    SourceTable = "MigrationQB Customer";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Customer Table';
    PromotedActionCategories = 'Related Entities';

    layout
    {
        area(content)
        {
            group(General)
            {
#pragma warning disable AA0218
                field(CompanyName; Rec.CompanyName) { ApplicationArea = All; }
                field(GivenName; Rec.GivenName) { ApplicationArea = All; }
                field(FamilyName; Rec.FamilyName) { ApplicationArea = All; }
                field(DisplayName; Rec.DisplayName) { ApplicationArea = All; }
                field(BillAddrLine1; Rec.BillAddrLine1) { ApplicationArea = All; }
                field(BillAddrLine2; Rec.BillAddrLine2) { ApplicationArea = All; }
                field(BillAddrCity; Rec.BillAddrCity) { ApplicationArea = All; }
                field(BillAddrCountry; Rec.BillAddrCountry) { ApplicationArea = All; }
                field(BillAddrPostalCode; Rec.BillAddrPostalCode) { ApplicationArea = All; }
                field(BillAddrCountrySubDivCode; Rec.BillAddrCountrySubDivCode) { ApplicationArea = All; }
                field(PrimaryPhone; Rec.PrimaryPhone) { ApplicationArea = All; }
                field(PrimaryEmailAddr; Rec.PrimaryEmailAddr) { ApplicationArea = All; }
                field(WebAddr; Rec.WebAddr) { ApplicationArea = All; }
                field(Fax; Rec.Fax) { ApplicationArea = All; }
                field(Taxable; Rec.Taxable) { ApplicationArea = All; }
                field(DefaultTaxCodeRef; Rec.DefaultTaxCodeRef) { ApplicationArea = All; }
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

                action(Transactions)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Transactions';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = EntriesList;
                    RunObject = Page "MigrationQB CustomerTrans";
                    RunPageLink = CustomerRef = field(ListId);
                    RunPageMode = Edit;
                    ToolTip = 'View QuickBooks customer transactions.';
                }
            }
        }
    }
}
