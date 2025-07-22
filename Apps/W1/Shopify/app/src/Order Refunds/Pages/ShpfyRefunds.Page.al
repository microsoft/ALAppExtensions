// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

page 30147 "Shpfy Refunds"
{
    ApplicationArea = All;
    Caption = 'Shopify Refunds';
    PageType = List;
    SourceTable = "Shpfy Refund Header";
    UsageCategory = Lists;
    Editable = false;
    CardPageId = "Shpfy Refund";
    SourceTableView = sorting("Created At") order(descending);

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Refund Id"; Rec."Refund Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Refund Id.';
                }
                field("Shopify Order No."; Rec."Shopify Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the order that appears on the order page in the Shopify admin and the order status page. For example, "#1001", "EN1001", or "1001-A".';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the refund was created in Shopify.';
                }
                field("Updated At"; Rec."Updated At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the refund was update in Shopify';
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
                    ToolTip = 'Specifies if this refunds already is processed into a Business Central document';
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
                    ToolTip = 'Specifies the last error information with the last process of this document.';
                    MultiLine = true;
                    Style = Attention;
                }
                field(CallStack; Rec.GetLastErrorCallStack())
                {
                    Caption = 'Error Call Stack';
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies the processing error callstack.';
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
                Enabled = CanCreateDocument and not MultipleSelected;

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
        }
        area(Promoted)
        {
            actionref(PromotedCreateCreditNoted; CreateCreditMemo) { }
        }
    }
    var
        CanCreateDocument: Boolean;
        MultipleSelected: Boolean;

    trigger OnAfterGetCurrRecord()
    var
        RefundHeader: Record "Shpfy Refund Header";
    begin
        CanCreateDocument := Rec.CheckCanCreateDocument();
        CurrPage.SetSelectionFilter(RefundHeader);
        MultipleSelected := RefundHeader.Count > 1;
    end;
}