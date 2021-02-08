page 4096 "GP Vendor"
{
    PageType = Card;
    SourceTable = "GP Vendor";
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
                field(VENDORID; VENDORID) { ApplicationArea = All; ToolTip = 'Vendor Id'; }
                field(VENDNAME; VENDNAME) { ApplicationArea = All; ToolTip = 'Vendor Name'; }
                field(SEARCHNAME; SEARCHNAME) { ApplicationArea = All; ToolTip = 'Search Name'; }
                field(VNDCHKNM; VNDCHKNM) { ApplicationArea = All; ToolTip = 'Vendor Check Number'; }
                field(ADDRESS1; ADDRESS1) { ApplicationArea = All; ToolTip = 'Address 1'; }
                field(ADDRESS2; ADDRESS2) { ApplicationArea = All; ToolTip = 'Address 2'; }
                field(CITY; CITY) { ApplicationArea = All; ToolTip = 'City'; }
                field(VNDCNTCT; VNDCNTCT) { ApplicationArea = All; ToolTip = 'VNDCNTCT'; }
                field(PHNUMBR1; PHNUMBR1) { ApplicationArea = All; ToolTip = 'Phone Number 1'; }
                field(PYMTRMID; PYMTRMID) { ApplicationArea = All; ToolTip = 'PYMTRMID'; }
                field(SHIPMTHD; SHIPMTHD) { ApplicationArea = All; ToolTip = 'Shipment Method'; }
                field(COUNTRY; COUNTRY) { ApplicationArea = All; ToolTip = 'Country'; }
                field(PYMNTPRI; PYMNTPRI) { ApplicationArea = All; ToolTip = 'PYMNTPRI'; }
                field(AMOUNT; AMOUNT) { ApplicationArea = All; ToolTip = 'Amount'; }
                field(FAXNUMBR; FAXNUMBR) { ApplicationArea = All; ToolTip = 'Fax Number'; }
                field(ZIPCODE; ZIPCODE) { ApplicationArea = All; ToolTip = 'Zip Code'; }
                field(STATE; STATE) { ApplicationArea = All; ToolTip = 'State'; }
                field(INET1; INET1) { ApplicationArea = All; ToolTip = 'Internet Address 1'; }
                field(INET2; INET2) { ApplicationArea = All; ToolTip = 'Internet Address 2'; }
                field(UPSZONE; UPSZONE) { ApplicationArea = All; ToolTip = 'UPS Zone'; }
                field(TXIDNMBR; TXIDNMBR) { ApplicationArea = All; ToolTip = 'Tax Id Number'; }

            }
        }
    }
}