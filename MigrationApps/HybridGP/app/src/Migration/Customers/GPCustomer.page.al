page 4093 "GP Customer"
{
    PageType = Card;
    SourceTable = "GP Customer";
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
                field(CUSTNMBR; 'Customer Id') { ApplicationArea = All; Caption = 'Customer Number'; ToolTip = 'Customer Number'; }
                field(CUSTNAME; CUSTNAME) { ApplicationArea = All; ToolTip = 'Customer Name'; }
                field(STMTNAME; STMTNAME) { ApplicationArea = All; ToolTip = 'Statement Name'; }
                field(ADDRESS1; ADDRESS1) { ApplicationArea = All; ToolTip = 'Address 1'; }
                field(ADDRESS2; ADDRESS2) { ApplicationArea = All; ToolTip = 'Address 2'; }
                field(CITY; CITY) { ApplicationArea = All; ToolTip = 'City'; }
                field(CNTCPRSN; CNTCPRSN) { ApplicationArea = All; ToolTip = 'CNTCPRSN'; }
                field(PHONE1; PHONE1) { ApplicationArea = All; ToolTip = 'Phone 1'; }
                field(SALSTERR; SALSTERR) { ApplicationArea = All; ToolTip = 'Sales Territory'; }
                field(CRLMTAMT; CRLMTAMT) { ApplicationArea = All; ToolTip = 'CRLMTAMT'; }
                field(PYMTRMID; PYMTRMID) { ApplicationArea = All; ToolTip = 'PYMTRMID'; }
                field(SLPRSNID; SLPRSNID) { ApplicationArea = All; ToolTip = 'Sales Person Id'; }
                field(SHIPMTHD; SHIPMTHD) { ApplicationArea = All; ToolTip = 'Shipment Method'; }
                field(COUNTRY; COUNTRY) { ApplicationArea = All; ToolTip = 'Country'; }
                field(AMOUNT; AMOUNT) { ApplicationArea = All; ToolTip = 'Amount'; }
                field(STMTCYCL; STMTCYCL) { ApplicationArea = All; ToolTip = 'Statement Cycle'; }
                field(ZIPCODE; ZIPCODE) { ApplicationArea = All; ToolTip = 'Zip Code'; }
                field(STATE; STATE) { ApplicationArea = All; ToolTip = 'State'; }
                field(INET1; INET1) { ApplicationArea = All; ToolTip = 'Internet Address 1'; }
                field(INET2; INET2) { ApplicationArea = All; ToolTip = 'Internet Address 2'; }
                field(UPSZONE; UPSZONE) { ApplicationArea = All; ToolTip = 'UPS Zone'; }
                field(TAXEXMT1; TAXEXMT1) { ApplicationArea = All; ToolTip = 'Tax Excempt 1'; }
            }
        }
    }
}