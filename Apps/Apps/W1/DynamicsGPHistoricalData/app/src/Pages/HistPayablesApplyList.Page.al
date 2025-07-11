namespace Microsoft.DataMigration.GP.HistoricalData;

page 41021 "Hist. Payables Apply List"
{
    ApplicationArea = All;
    Caption = 'Historical Payables Apply Lines';
    PageType = ListPart;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Payables Apply";
    CardPageId = "Hist. Payables Apply";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Apply To Document No."; Rec."Apply To Document No.")
                {
                    ToolTip = 'Specifies the value of the Apply To Document No. field.';
                    Visible = not IsInvoice;
                }
                field("Apply To Document Type"; Rec."Apply To Document Type")
                {
                    ToolTip = 'Specifies the value of the Apply To Document Type field.';
                    Visible = not IsInvoice;
                }
                field("Apply To Document Date"; Rec."Apply To Document Date")
                {
                    ToolTip = 'Specifies the value of the Apply To Document Date field.';
                    Visible = not IsInvoice;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                    Visible = IsInvoice;
                }
                field("Voucher No."; Rec."Voucher No.")
                {
                    ToolTip = 'Specifies the value of the Voucher No. field.';
                    Visible = IsInvoice;
                }
                field("Document Amount"; Rec."Document Amount")
                {
                    ToolTip = 'Specifies the value of the Document Amount field.';
                    Visible = IsInvoice;
                }
                field("Apply To Voucher No."; Rec."Apply To Voucher No.")
                {
                    ToolTip = 'Specifies the value of the Apply To Voucher No. field.';
                    Visible = not IsInvoice;
                }
                field("Apply To Post Date"; Rec."Apply To Post Date")
                {
                    ToolTip = 'Specifies the value of the Apply To Post Date field.';
                }
                field("Apply From Document No."; Rec."Apply From Document No.")
                {
                    ToolTip = 'Specifies the value of the Apply From Document No. field.';
                    Visible = IsInvoice;
                }
                field("Apply From Apply Amount"; Rec."Apply From Apply Amount")
                {
                    ToolTip = 'Specifies the value of the Apply From Apply Amount field.';
                    Visible = not IsInvoice;
                }
                field("Disc. Taken Amount"; Rec."Disc. Taken Amount")
                {
                    ToolTip = 'Specifies the value of the Disc. Taken Amount field.';
                }
            }
        }
    }

    procedure FilterByVoucherNo(DocType: Enum "Hist. Payables Doc. Type"; VoucherNo: Code[35])
    begin
        ParentDocType := DocType;
        ParentVoucherNo := VoucherNo;
    end;

    trigger OnAfterGetRecord()
    begin
        ApplyFilters();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ApplyFilters();
    end;

    local procedure ApplyFilters()
    begin
        if ParentDocType = Rec."Document Type"::Invoice then begin
            IsInvoice := true;
            Rec.SetRange("Apply To Voucher No.", ParentVoucherNo)
        end else
            Rec.SetRange("Voucher No.", ParentVoucherNo);
    end;

    var
        ParentDocType: Enum "Hist. Payables Doc. Type";
        ParentVoucherNo: Code[35];
        IsInvoice: Boolean;
}