#if not CLEAN26
namespace Microsoft.DataMigration.GP;

page 4096 "GP Vendor"
{
    PageType = Card;
    SourceTable = "GP Vendor";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Vendor Table';
    PromotedActionCategories = 'Related Entities';
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteReason = 'Removing the GP staging table pages because they cause confusion and should not be used.';
    ObsoleteTag = '26.0';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(VENDORID; Rec.VENDORID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Vendor Id';
                }
                field(VENDNAME; Rec.VENDNAME)
                {
                    ApplicationArea = All;
                    ToolTip = 'Vendor Name';
                }
                field(SEARCHNAME; Rec.SEARCHNAME)
                {
                    ApplicationArea = All;
                    ToolTip = 'Search Name';
                }
                field(VNDCHKNM; Rec.VNDCHKNM)
                {
                    ApplicationArea = All;
                    ToolTip = 'Vendor Check Number';
                }
                field(ADDRESS1; Rec.ADDRESS1)
                {
                    ApplicationArea = All;
                    ToolTip = 'Address 1';
                }
                field(ADDRESS2; Rec.ADDRESS2)
                {
                    ApplicationArea = All;
                    ToolTip = 'Address 2';
                }
                field(CITY; Rec.CITY)
                {
                    ApplicationArea = All;
                    ToolTip = 'City';
                }
                field(VNDCNTCT; Rec.VNDCNTCT)
                {
                    ApplicationArea = All;
                    ToolTip = 'VNDCNTCT';
                }
                field(PHNUMBR1; Rec.PHNUMBR1)
                {
                    ApplicationArea = All;
                    ToolTip = 'Phone Number 1';
                }
                field(PYMTRMID; Rec.PYMTRMID)
                {
                    ApplicationArea = All;
                    ToolTip = 'PYMTRMID';
                }
                field(SHIPMTHD; Rec.SHIPMTHD)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shipment Method';
                }
                field(COUNTRY; Rec.COUNTRY)
                {
                    ApplicationArea = All;
                    ToolTip = 'Country';
                }
                field(PYMNTPRI; Rec.PYMNTPRI)
                {
                    ApplicationArea = All;
                    ToolTip = 'PYMNTPRI';
                }
                field(AMOUNT; Rec.AMOUNT)
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount';
                }
                field(FAXNUMBR; Rec.FAXNUMBR)
                {
                    ApplicationArea = All;
                    ToolTip = 'Fax Number';
                }
                field(ZIPCODE; Rec.ZIPCODE)
                {
                    ApplicationArea = All;
                    ToolTip = 'Zip Code';
                }
                field(STATE; Rec.STATE)
                {
                    ApplicationArea = All;
                    ToolTip = 'State';
                }
                field(INET1; Rec.INET1)
                {
                    ApplicationArea = All;
                    ToolTip = 'Internet Address 1';
                }
                field(INET2; Rec.INET2)
                {
                    ApplicationArea = All;
                    ToolTip = 'Internet Address 2';
                }
                field(UPSZONE; Rec.UPSZONE)
                {
                    ApplicationArea = All;
                    ToolTip = 'UPS Zone';
                }
                field(TXIDNMBR; Rec.TXIDNMBR)
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax Id Number';
                }

            }
        }
    }
}
#endif