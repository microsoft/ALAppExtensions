namespace Microsoft.Integration.Shopify;

page 30145 "Shpfy Refund"
{
    ApplicationArea = All;
    Caption = 'Shopify Refund';
    PageType = Document;
    SourceTable = "Shpfy Refund Header";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Shopify Order No."; Rec."Shopify Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the order that appears on the order page in the Shopify admin and the order status page. For example, "#1001", "EN1001", or "1001-A".';
                }
                field("Refund Id"; Rec."Refund Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Refund Id.';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the refund was created in Shopify.';
                }
                field("Updated At"; Rec."Updated At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the refund was update in Shopify.';
                    Visible = false;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sell-to Customer No.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sell-to Customer Name';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Bill-to Customer No.';
                }
                field("Bill-to Customer Name"; Rec."Bill-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Bill-to Customer Name.';
                }
                field("Total Refunded Amount"; Rec."Total Refunded Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount across all transactions for the refund.';
                }
                field("Return No."; Rec."Return No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shopify return associated with the refund.';
                }
                field("Is Processed"; Rec."Is Processed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this refunds already is processed into a Business Central document.';
                }
            }
            part(Lines; "Shpfy Refund Lines")
            {
                ApplicationArea = All;
                Caption = 'Lines';
                SubPageLink = "Refund Id" = field("Refund Id");
            }
            group(NoteGroup)
            {
                Caption = 'Note';
                Visible = HasNote;

                field(Note; Rec.GetNote())
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the Note.';
                }
            }
            group(LastErrorInfo)
            {
                Caption = 'Last Error Info';
                Visible = Rec."Has Processing Error";

                field("Last Error Description"; Rec.GetLastErrorDescription())
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Last error information with the last process of this document.';
                    MultiLine = true;
                    Style = Attention;
                }
            }
        }
        area(FactBoxes)
        {
            part(LinkedBCDocuments; "Shpfy Linked To Documents")
            {
                Caption = 'Linked Documents';
                SubPageLink = "Shopify Document Type" = const("Shpfy Shop Document Type"::"Shopify Shop Refund"), "Shopify Document Id" = field("Refund Id");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CreateCreditMemo)
            {
                Caption = 'Create Credit Memo';
                Image = CreateCreditMemo;
                ToolTip = 'Create a credit memo for this refund.';
                Enabled = CanCreateDocument;

                trigger OnAction()
                var
                    RefundsAPI: Codeunit "Shpfy Refunds API";
                    IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
                    ErrorInfo: ErrorInfo;
                begin
                    RefundsAPI.VerifyRefundCanCreateCreditMemo(Rec."Refund Id");
                    IReturnRefundProcess := "Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo";
                    if IReturnRefundProcess.CanCreateSalesDocumentFor("Shpfy Source Document Type"::Refund, Rec."Refund Id", ErrorInfo) then
                        IReturnRefundProcess.CreateSalesDocument("Shpfy Source Document Type"::Refund, Rec."Refund Id")
                    else
                        Error(ErrorInfo);
                end;
            }
            action(RetrievedShopifyData)
            {
                ApplicationArea = All;
                Caption = 'Retrieved Shopify Data';
                Image = Entry;
                ToolTip = 'View the data retrieved from Shopify.';

                trigger OnAction();
                var
                    DataCapture: Record "Shpfy Data Capture";
                begin
                    DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
                    DataCapture.SetRange("Linked To Table", Database::"Shpfy Refund Header");
                    DataCapture.SetRange("Linked To Id", Rec.SystemId);
                    Page.Run(Page::"Shpfy Data Capture List", DataCapture);
                end;
            }
        }
        area(Navigation)
        {
            action(ShippingLines)
            {
                ApplicationArea = All;
                Caption = 'Shipping Lines';
                Image = OrderList;
                ToolTip = 'View the shipping lines for this refund.';
                RunObject = Page "Shpfy Refund Shipping Lines";
                RunPageLink = "Refund Id" = field("Refund Id");
            }
        }
        area(Promoted)
        {
            actionref(PromotedShippingLines; ShippingLines) { }
            actionref(PromotedCreateCreditNoted; CreateCreditMemo) { }
            actionref(PromotedRetrievedShopifyData; RetrievedShopifyData) { }
        }
    }

    var
        HasNote: Boolean;
        CanCreateDocument: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        HasNote := Rec.Note.HasValue();
        CanCreateDocument := Rec.CheckCanCreateDocument();
    end;
}