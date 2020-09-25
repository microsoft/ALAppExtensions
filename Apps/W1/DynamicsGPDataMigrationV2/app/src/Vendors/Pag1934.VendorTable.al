page 1934 "MigrationGP VendorTable"
{
    PageType = Card;
    SourceTable = "MigrationGP Vendor";
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
                field(VENDORID; VENDORID) { ApplicationArea = All; }
                field(VENDNAME; VENDNAME) { ApplicationArea = All; }
                field(SEARCHNAME; SEARCHNAME) { ApplicationArea = All; }
                field(VNDCHKNM; VNDCHKNM) { ApplicationArea = All; }
                field(ADDRESS1; ADDRESS1) { ApplicationArea = All; }
                field(ADDRESS2; ADDRESS2) { ApplicationArea = All; }
                field(CITY; CITY) { ApplicationArea = All; }
                field(VNDCNTCT; VNDCNTCT) { ApplicationArea = All; }
                field(PHNUMBR1; PHNUMBR1) { ApplicationArea = All; }
                field(PYMTRMID; PYMTRMID) { ApplicationArea = All; }
                field(SHIPMTHD; SHIPMTHD) { ApplicationArea = All; }
                field(COUNTRY; COUNTRY) { ApplicationArea = All; }
                field(PYMNTPRI; PYMNTPRI) { ApplicationArea = All; }
                field(AMOUNT; AMOUNT) { ApplicationArea = All; }
                field(FAXNUMBR; FAXNUMBR) { ApplicationArea = All; }
                field(ZIPCODE; ZIPCODE) { ApplicationArea = All; }
                field(STATE; STATE) { ApplicationArea = All; }
                field(INET1; INET1) { ApplicationArea = All; }
                field(INET2; INET2) { ApplicationArea = All; }
                field(UPSZONE; UPSZONE) { ApplicationArea = All; }
                field(TXIDNMBR; TXIDNMBR) { ApplicationArea = All; }

            }
        }
    }
}