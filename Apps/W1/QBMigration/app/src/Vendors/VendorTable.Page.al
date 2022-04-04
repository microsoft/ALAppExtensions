page 1914 "MigrationQB VendorTable"
{
    PageType = Card;
    SourceTable = "MigrationQB Vendor";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Vendor Table';
    PromotedActionCategories = 'Related Entities';

    layout
    {
        area(content)
        {
            group(General)
            {
#pragma warning disable AA0218
                field(GivenName; GivenName) { ApplicationArea = All; }
                field(FamilyName; FamilyName) { ApplicationArea = All; }
                field(CompanyName; CompanyName) { ApplicationArea = All; }
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
                    Caption = 'Vendor Transactions';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = EntriesList;
                    RunObject = Page "MigrationQB VendorTrans";
                    RunPageLink = VendorRef = field (ListId);
                    RunPageMode = Edit;
                }
            }
        }
    }
}