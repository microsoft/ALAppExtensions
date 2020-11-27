report 11704 "All Payments on Hold CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/AllPaymentsonHold.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'All Payments on Hold';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", Name;
            column(USERID; UserId)
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName())
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(Vendor_TABLECAPTION__________VendLedgEntryFilter; TableCaption + ': ' + VendLedgEntryFilter)
            {
            }
            column(Vendor__No__; "No.")
            {
            }
            column(Vendor_Name; Name)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Payments_on_HoldCaption; Payments_on_HoldCaptionLbl)
            {
            }
            column(Vendor__No__Caption; FieldCaption("No."))
            {
            }
            column(Vendor_NameCaption; FieldCaption(Name))
            {
            }
            column(Vendor_Ledger_Entry__On_Hold_Caption; "Vendor Ledger Entry".FieldCaption("On Hold"))
            {
            }
            column(Vendor_Ledger_Entry__Remaining_Amt___LCY__Caption; "Vendor Ledger Entry".FieldCaption("Remaining Amt. (LCY)"))
            {
            }
            column(Vendor_Ledger_Entry__Remaining_Amount_Caption; "Vendor Ledger Entry".FieldCaption("Remaining Amount"))
            {
            }
            column(Vendor_Ledger_Entry_DescriptionCaption; "Vendor Ledger Entry".FieldCaption(Description))
            {
            }
            column(Vendor_Ledger_Entry__Document_No__Caption; "Vendor Ledger Entry".FieldCaption("Document No."))
            {
            }
            column(Vendor_Ledger_Entry__Document_Type_Caption; Vendor_Ledger_Entry__Document_Type_CaptionLbl)
            {
            }
            column(Vendor_Ledger_Entry__Posting_Date_Caption; "Vendor Ledger Entry".FieldCaption("Posting Date"))
            {
            }
            column(Vendor_Ledger_Entry__Due_Date_Caption; Vendor_Ledger_Entry__Due_Date_CaptionLbl)
            {
            }
            dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
            {
                DataItemLink = "Vendor No." = field("No.");
                DataItemTableView = sorting("Vendor No.", Open, Positive, "Due Date") WHERE(Open = CONST(true), "On Hold" = FILTER(<> ''));
                column(Vendor_Ledger_Entry__Due_Date_; "Due Date")
                {
                }
                column(Vendor_Ledger_Entry__Posting_Date_; "Posting Date")
                {
                }
                column(Vendor_Ledger_Entry__Document_Type_; "Document Type")
                {
                }
                column(Vendor_Ledger_Entry__Document_No__; "Document No.")
                {
                }
                column(Vendor_Ledger_Entry_Description; Description)
                {
                }
                column(Vendor_Ledger_Entry__Remaining_Amount_; "Remaining Amount")
                {
                }
                column(Vendor_Ledger_Entry__Currency_Code_; "Currency Code")
                {
                }
                column(Vendor_Ledger_Entry__On_Hold_; "On Hold")
                {
                }
                column(Vendor_Ledger_Entry__Remaining_Amt___LCY__; "Remaining Amt. (LCY)")
                {
                }
                column(Vendor_Ledger_Entry_Entry_No_; "Entry No.")
                {
                }
                column(Vendor_Ledger_Entry_Vendor_No_; "Vendor No.")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    CalcFields("Remaining Amt. (LCY)");
                    VendorTotal += "Remaining Amt. (LCY)";
                end;

                trigger OnPreDataItem()
                begin
                    if DueDate <> 0D then
                        SetFilter("Due Date", '..%1', DueDate);
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number) WHERE(Number = CONST(1));
                column(gdeVendorTotal; VendorTotal)
                {
                }
                column(gdeVendorTotalCaption; VendorTotalCaptionLbl)
                {
                }
                column(Integer_Number; Number)
                {
                }
                trigger OnPreDataItem()
                begin
                    if VendorTotal = 0 then
                        CurrReport.Break();
                end;
            }
            trigger OnAfterGetRecord()
            begin
                VendorTotal := 0;
            end;
        }
    }
    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DueDateField; DueDate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Last Due Date';
                        ToolTip = 'Specifies the last due date for the entrie''s filter.';
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        VendLedgEntryFilter := Vendor.GetFilters;
    end;

    var
        VendLedgEntryFilter: Text;
        VendorTotal: Decimal;
        DueDate: Date;
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Payments_on_HoldCaptionLbl: Label 'Payments on Hold';
        Vendor_Ledger_Entry__Document_Type_CaptionLbl: Label 'Document Type';
        Vendor_Ledger_Entry__Due_Date_CaptionLbl: Label 'Due Date';
        VendorTotalCaptionLbl: Label 'Total (LCY)';
}
