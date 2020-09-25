page 1932 "MigrationGP CustomerTable"
{
    PageType = Card;
    SourceTable = "MigrationGP Customer";
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
                field(CUSTNMBR; 'Customer Id') { ApplicationArea = All; }
                field(CUSTNAME; CUSTNAME) { ApplicationArea = All; }
                field(STMTNAME; STMTNAME) { ApplicationArea = All; }
                field(ADDRESS1; ADDRESS1) { ApplicationArea = All; }
                field(ADDRESS2; ADDRESS2) { ApplicationArea = All; }
                field(CITY; CITY) { ApplicationArea = All; }
                field(CNTCPRSN; CNTCPRSN) { ApplicationArea = All; }
                field(PHONE1; PHONE1) { ApplicationArea = All; }
                field(SALSTERR; SALSTERR) { ApplicationArea = All; }
                field(CRLMTAMT; CRLMTAMT) { ApplicationArea = All; }
                field(PYMTRMID; PYMTRMID) { ApplicationArea = All; }
                field(SLPRSNID; SLPRSNID) { ApplicationArea = All; }
                field(SHIPMTHD; SHIPMTHD) { ApplicationArea = All; }
                field(COUNTRY; COUNTRY) { ApplicationArea = All; }
                field(AMOUNT; AMOUNT) { ApplicationArea = All; }
                field(STMTCYCL; STMTCYCL) { ApplicationArea = All; }
                field(ZIPCODE; ZIPCODE) { ApplicationArea = All; }
                field(STATE; STATE) { ApplicationArea = All; }
                field(INET1; INET1) { ApplicationArea = All; }
                field(INET2; INET2) { ApplicationArea = All; }
                field(UPSZONE; UPSZONE) { ApplicationArea = All; }
                field(TAXEXMT1; TAXEXMT1) { ApplicationArea = All; }
            }
        }
    }
}