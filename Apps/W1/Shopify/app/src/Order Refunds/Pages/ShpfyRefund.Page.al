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
                    ToolTip = 'The unique identifier for the order that appears on the order page in the Shopify admin and the order status page. For example, "#1001", "EN1001", or "1001-A".';
                }
                field("Refund Id"; Rec."Refund Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Refund Id.';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'The date and time when the refund was created in Shopify.';
                }
                field("Updated At"; Rec."Updated At")
                {
                    ApplicationArea = All;
                    ToolTip = 'The date and time when the refund was update in Shopify';
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
                    ToolTip = 'The total amount across all transactions for the refund.';
                }
                field("Return No."; Rec."Return No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The shopify retour no. of the document.';
                }
                field("Is Processed"; Rec."Is Processed")
                {
                    ApplicationArea = All;
                    ToolTip = 'If this refunds already is processed into a BC document';
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
                }
            }
        }
        area(FactBoxes)
        {
            part(LinkedBCDocuments; "Shpfy Linked BC Documents")
            {
                Caption = 'Linked BC Documents';
                SubPageLink = "Shopify Document Type" = const("Shpfy Document Type"::"Shopify Refund"), "Shopify Document Id" = field("Refund Id");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CreateCreditNote)
            {
                Caption = 'Create Credit Note';
                Image = CreateCreditMemo;
                ToolTip = 'Create a credit note for this refund.';
                Enabled = CanCreateDocument;

                trigger OnAction()
                var
                    IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
                    ErrorInfo: ErrorInfo;
                begin
                    IReturnRefundProcess := "Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo";
                    if IReturnRefundProcess.CanCreateSalesDocumentFor("Shpfy Source Document Type"::Refund, Rec."Refund Id", ErrorInfo) then
                        IReturnRefundProcess.CreateSalesDocument("Shpfy Source Document Type"::Refund, Rec."Refund Id")
                    else
                        Error(ErrorInfo);
                end;
            }
        }
        area(Promoted)
        {
            actionref(PromotedCreateCreditNoted; CreateCreditNote) { }
        }
    }

    var
        HasNote: Boolean;
        CanCreateDocument: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        HasNote := Rec.Note.HasValue();
        CanCreateDocument := CheckCanCreateDocument();
    end;

    local procedure CheckCanCreateDocument(): Boolean
    var
        DocLinkToBCDoc: Record "Shpfy Doc. Link To BC Doc.";
    begin
        DocLinkToBCDoc.SetRange("Shopify Document Type", "Shpfy Document Type"::"Shopify Refund");
        DocLinkToBCDoc.SetRange("Shopify Document Id", Rec."Refund Id");
        DocLinkToBCDoc.SetCurrentKey("Shopify Document Type", "Shopify Document Id");
        exit(DocLinkToBCDoc.IsEmpty);
    end;
}
