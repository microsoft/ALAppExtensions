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
                field(CompanyName; CompanyName) { ApplicationArea = All; }
                field(GivenName; GivenName) { ApplicationArea = All; }
                field(FamilyName; FamilyName) { ApplicationArea = All; }
                field(DisplayName; DisplayName) { ApplicationArea = All; }
                field(BillAddrLine1; BillAddrLine1) { ApplicationArea = All; }
                field(BillAddrLine2; BillAddrLine2) { ApplicationArea = All; }
                field(BillAddrCity; BillAddrCity) { ApplicationArea = All; }
                field(BillAddrCountry; BillAddrCountry) { ApplicationArea = All; }
                field(BillAddrPostalCode; BillAddrPostalCode) { ApplicationArea = All; }
                field(BillAddrCountrySubDivCode; BillAddrCountrySubDivCode) { ApplicationArea = All; }
                field(PrimaryPhone; PrimaryPhone) { ApplicationArea = All; }
                field(PrimaryEmailAddr; PrimaryEmailAddr) { ApplicationArea = All; }
                field(WebAddr; WebAddr) { ApplicationArea = All; }
                field(Fax; Fax) { ApplicationArea = All; }
                field(Taxable; Taxable) { ApplicationArea = All; }
                field(DefaultTaxCodeRef; DefaultTaxCodeRef) { ApplicationArea = All; }
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
                    RunPageLink = CustomerRef = field (ListId);
                    RunPageMode = Edit;
                }
            }
        }
    }
}