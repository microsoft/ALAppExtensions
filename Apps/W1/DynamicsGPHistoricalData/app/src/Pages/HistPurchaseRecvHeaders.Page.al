namespace Microsoft.DataMigration.GP.HistoricalData;

page 41014 "Hist. Purchase Recv. Headers"
{
    ApplicationArea = All;
    Caption = 'Historical Purchase Recv. List';
    PageType = List;
    CardPageId = "Hist. Purchase Recv.";
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Purchase Recv. Header";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Vendor Document No."; Rec."Vendor Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Document No. field.';
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Date field.';
                }
                field("Invoice Receipt Date"; Rec."Invoice Receipt Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice Receipt Date field.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Due Date field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Amount field.';
                }
                field("Misc. Amount"; Rec."Misc. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Misc. Amount field.';
                }
                field("Freight Amount"; Rec."Freight Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Freight Amount field.';
                }
                field("Trade Discount Amount"; Rec."Trade Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trade Discount Amount field.';
                }
                field(Subtotal; Rec.Subtotal)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subtotal field.';
                }
                field("Prepayment Amount"; Rec."Prepayment Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prepayment Amount field.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Name field.';
                }
                field("Payment Terms ID"; Rec."Payment Terms ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Terms ID field.';
                }
                field("Discount Date"; Rec."Discount Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Date field.';
                }
                field("Discount Percent Amount"; Rec."Discount Percent Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Percent Amount field.';
                }
                field("Discount Available Amount"; Rec."Discount Available Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Available Amount field.';
                }
                field("Discount Dollar Amount"; Rec."Discount Dollar Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Dollar Amount field.';
                }
                field("1099 Amount"; Rec."1099 Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 1099 Amount field.';
                }
                field(Reference; Rec.Reference)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference field.';
                }
                field("Voucher No."; Rec."Voucher No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher No. field.';
                }
                field("Audit Code"; Rec."Audit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Code field.';
                }
                field("Batch No."; Rec."Batch No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Batch No. field.';
                }
                field("Actual Ship Date"; Rec."Actual Ship Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Actual Ship Date field.';
                }
                field("Post Date"; Rec."Post Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Date field.';
                }
                field(Void; Rec.Void)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Void field.';
                }
                field(User; Rec.User)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if FilterVendorNo <> '' then
            Rec.SetFilter("Vendor No.", FilterVendorNo);
    end;

    procedure SetFilterVendorNo(VendorNo: Code[35])
    begin
        FilterVendorNo := VendorNo;
    end;

    var
        FilterVendorNo: Code[35];
}