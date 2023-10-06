namespace Microsoft.DataMigration.GP.HistoricalData;

page 41002 "Hist. Sales Trx. Headers"
{
    ApplicationArea = All;
    Caption = 'Historical Sales Transactions';
    PageType = List;
    CardPageId = "Hist. Sales Trx.";
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Sales Trx. Header";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Main)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field("Sales Trx. Status"; Rec."Sales Trx. Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Trx. Status field.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Date field.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Due Date field.';
                }
                field("Actual Ship Date"; Rec."Actual Ship Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Actual Ship Date field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Sub Total"; Rec."Sub Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sub Total field.';
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ext. Price field.';
                }
                field("Trade Disc. Amount"; Rec."Trade Disc. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trade Discount Amount field.';
                }
                field("Freight Amount"; Rec."Freight Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Freight Amount field.';
                }
                field("Misc. Amount"; Rec."Misc. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Miscellaneous Amount field.';
                }
                field("Payment Recv. Amount"; Rec."Payment Recv. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Received Amount field.';
                }
                field("Disc. Taken Amount"; Rec."Disc. Taken Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Taken Amount field.';
                }
                field(Total; Rec.Total)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Name field.';
                }
                field("Contact Person Name"; Rec."Contact Person Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Person Name field.';
                }
                field("Sales Territory"; Rec."Sales Territory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Territory field.';
                }
                field("Salesperson No."; Rec."Salesperson No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson No. field.';
                }
                field("Ship Method"; Rec."Ship Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship Method field.';
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Code field.';
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Name field.';
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Address field.';
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Address 2 field.';
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to City field.';
                }
                field("Ship-to State"; Rec."Ship-to State")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to State field.';
                }
                field("Ship-to Zipcode"; Rec."Ship-to Zipcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Zipcode field.';
                }
                field("Ship-to Country"; Rec."Ship-to Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Country field.';
                }
                field("Original No."; Rec."Original No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Original No. field.';
                }
                field("Customer Purchase No."; Rec."Customer Purchase No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Purchase No. field.';
                }
                field("Audit Code"; Rec."Audit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Code field.';
                }
                field("Sales Trx. Type"; Rec."Sales Trx. Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Type field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if FilterCustomerNo <> '' then
            Rec.SetFilter("Customer No.", FilterCustomerNo);
    end;

    procedure SetFilterCustomerNo(CustomerNo: Code[35])
    begin
        FilterCustomerNo := CustomerNo;
    end;

    var
        FilterCustomerNo: Code[35];
}