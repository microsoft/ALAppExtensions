namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Document;

pageextension 8071 "Purch Invoice Subform" extends "Purch. Invoice Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Attached to Contract Line"; Rec."Attached to Contract line")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that the invoice line is linked to a contract line.';
            }
        }
    }
    actions
    {
        addlast("Related Information")
        {
            action(ShowBillingLines)
            {
                ApplicationArea = All;
                Caption = 'Billing Lines';
                Image = AllLines;
                ToolTip = 'Show Billing Lines.';
                Scope = Repeater;
                Enabled = IsConnectedToBillingLine;

                trigger OnAction()
                begin
                    ContractsGeneralMgt.ShowBillingLinesForDocumentLine(Rec."Document Type", Rec."Document No.", Rec."Line No.");
                end;
            }
            action("Usage Data")
            {
                ApplicationArea = All;
                Caption = 'Usage Data';
                Image = DataEntry;
                Scope = Repeater;
                ToolTip = 'Shows the related usage data.';

                trigger OnAction()
                var
                    UsageDataBilling: Record "Usage Data Billing";
                    UsageBasedDocTypeConv: Codeunit "Usage Based Doc. Type Conv.";
                begin
                    UsageDataBilling.FilterOnDocumentTypeAndDocumentNo(UsageBasedDocTypeConv.ConvertPurchaseDocTypeToUsageBasedBillingDocType(Rec."Document Type"), Rec."Document No.");
                    UsageDataBilling.SetRange("Document Line No.", Rec."Line No.");
                    Page.RunModal(Page::"Usage Data Billings", UsageDataBilling);
                end;
            }
            action("Assign Contract Line")
            {
                ApplicationArea = All;
                Caption = 'Assign Contract Line';
                Image = GetOrder;
                ToolTip = 'Select a corresponding Vendor Contract line.';
                Enabled = ContractLineCanBeAssigned;

                trigger OnAction()
                begin
                    Rec.AssignVendorContractLine();
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        IsConnectedToBillingLine := Rec.IsLineAttachedToBillingLine();
        ContractLineCanBeAssigned := Rec.IsContractLineAssignable();
    end;

    var
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        IsConnectedToBillingLine: Boolean;
        ContractLineCanBeAssigned: Boolean;
}
