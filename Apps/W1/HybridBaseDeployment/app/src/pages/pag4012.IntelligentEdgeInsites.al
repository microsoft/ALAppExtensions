page 4012 "Intelligent Edge Insights"
{
    PageType = CardPart;
    Caption = 'Insight';

    layout
    {
        area(Content)
        {
            field(OverDueInvoices; "Over Due Sales Invoices")
            {
                ApplicationArea = All;
                ShowCaption = false;
                Editable = false;
                trigger OnDrillDown()
                var
                    CalculateAmts: Codeunit CalculateAmounts;
                begin
                    CalculateAmts.DrillDownNumOfOverDueSalesInvoice();
                end;
            }
            field(SalesInvoicesDueThisWeek; "Sales Invoices Due This Week")
            {
                ApplicationArea = All;
                ShowCaption = false;
                Editable = false;
                trigger OnDrillDown()
                var
                    CalculateAmts: Codeunit CalculateAmounts;
                begin
                    CalculateAmts.DrillDownNumOfSalesInvoicesDueThisWeek();
                end;
            }
            field(OverDuePurchaseInvoices; "Over Due Purchase Invoices")
            {
                ApplicationArea = All;
                ShowCaption = false;
                Editable = false;
                trigger OnDrillDown()
                var
                    CalculateAmts: Codeunit CalculateAmounts;
                begin
                    CalculateAmts.DrillDownNumOfPurchInvoicesOverDue();
                end;
            }
            field(PurchaseInvoicesDueToday; "Purchase Invoices Due This Week")
            {
                ApplicationArea = All;
                ShowCaption = false;
                Editable = false;
                trigger OnDrillDown()
                var
                    CalculateAmts: Codeunit CalculateAmounts;
                begin
                    CalculateAmts.DrillDownNumOfPurchInvoicesDueThisWeek();
                end;
            }
        }
    }

    var
        "Over Due Sales Invoices": text;
        "Sales Invoices Due This Week": text;
        "Over Due Purchase Invoices": text;
        "Purchase Invoices Due This Week": Text;

    trigger OnOpenPage()
    var
        CalculateAmounts: Codeunit CalculateAmounts;
    begin
        "Over Due Sales Invoices" := CalculateAmounts.NumOfOverDueSalesInvoice();
        "Sales Invoices Due This Week" := CalculateAmounts.NumOfSalesInvoicesDueThisWeek();
        "Over Due Purchase Invoices" := CalculateAmounts.NumOfPurchInvoicesOverDue();
        "Purchase Invoices Due This Week" := CalculateAmounts.NumOfPurchInvoicesDueThisWeek();
    end;
}