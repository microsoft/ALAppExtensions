#if not CLEAN26
namespace Microsoft.DataMigration.GP;

page 4093 "GP Customer"
{
    PageType = Card;
    SourceTable = "GP Customer";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'Customer Table';
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
                field(CUSTNMBR; 'Customer Id')
                {
                    ApplicationArea = All;
                    Caption = 'Customer Number';
                    ToolTip = 'Customer Number';
                }
                field(CUSTNAME; Rec.CUSTNAME)
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer Name';
                }
                field(STMTNAME; Rec.STMTNAME)
                {
                    ApplicationArea = All;
                    ToolTip = 'Statement Name';
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
                field(CNTCPRSN; Rec.CNTCPRSN)
                {
                    ApplicationArea = All;
                    ToolTip = 'CNTCPRSN';
                }
                field(PHONE1; Rec.PHONE1)
                {
                    ApplicationArea = All;
                    ToolTip = 'Phone 1';
                }
                field(SALSTERR; Rec.SALSTERR)
                {
                    ApplicationArea = All;
                    ToolTip = 'Sales Territory';
                }
                field(CRLMTAMT; Rec.CRLMTAMT)
                {
                    ApplicationArea = All;
                    ToolTip = 'CRLMTAMT';
                }
                field(PYMTRMID; Rec.PYMTRMID)
                {
                    ApplicationArea = All;
                    ToolTip = 'PYMTRMID';
                }
                field(SLPRSNID; Rec.SLPRSNID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Sales Person Id';
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
                field(AMOUNT; Rec.AMOUNT)
                {
                    ApplicationArea = All;
                    ToolTip = 'Amount';
                }
                field(STMTCYCL; Rec.STMTCYCL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Statement Cycle';
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
                field(TAXEXMT1; Rec.TAXEXMT1)
                {
                    ApplicationArea = All;
                    ToolTip = 'Tax Excempt 1';
                }
            }
        }
    }
}
#endif