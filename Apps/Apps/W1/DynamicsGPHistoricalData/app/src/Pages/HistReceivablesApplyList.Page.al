namespace Microsoft.DataMigration.GP.HistoricalData;

page 41022 "Hist. Receivables Apply List"
{
    ApplicationArea = All;
    Caption = 'Historical Receivables Apply Lines';
    PageType = ListPart;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Receivables Apply";
    CardPageId = "Hist. Receivables Apply";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Date"; Rec."Date")
                {
                    Caption = 'Trx. Date';
                    ToolTip = 'Specifies the value of the Date field.';
                }
                field("Apply From Document No."; Rec."Apply From Document No.")
                {
                    ToolTip = 'Specifies the value of the Apply From Document No. field.';
                    Visible = IsInvoice;
                }
                field("Apply From Document Type"; Rec."Apply From Document Type")
                {
                    ToolTip = 'Specifies the value of the Apply From Document Type field.';
                    Visible = IsInvoice;
                }
                field("Apply From Apply Amount"; Rec."Apply From Apply Amount")
                {
                    ToolTip = 'Specifies the value of the Apply From Apply Amount field.';
                    Visible = IsInvoice;
                }
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
                field("Apply To Amount"; Rec."Apply To Amount")
                {
                    ToolTip = 'Specifies the value of the Apply To Amount field.';
                    Visible = not IsInvoice;
                }
                field("Discount Taken Amount"; Rec."Discount Taken Amount")
                {
                    ToolTip = 'Specifies the value of the Discount Taken Amount field.';
                }
                field("Write Off Amount"; Rec."Write Off Amount")
                {
                    ToolTip = 'Specifies the value of the Write Off Amount field.';
                }
            }
        }
    }

    procedure FilterByDocumentNo(DocType: Enum "Hist. Receivables Doc. Type"; DocumentNo: Code[35])
    begin
        ParentDocType := DocType;
        ParentDocumentNo := DocumentNo;
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
        if ParentDocType = "Hist. Receivables Doc. Type"::SaleOrInvoice then
            IsInvoice := true;

        Rec.SetRange("Apply To Document No.", ParentDocumentNo);

        if (Rec.IsEmpty) then begin
            Rec.SetRange("Apply To Document No.");
            Rec.SetRange("Apply From Document No.", ParentDocumentNo);
        end;
    end;

    var
        ParentDocType: Enum "Hist. Receivables Doc. Type";
        ParentDocumentNo: Code[35];
        IsInvoice: Boolean;
}