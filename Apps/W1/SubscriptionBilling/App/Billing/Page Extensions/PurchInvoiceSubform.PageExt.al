namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Document;

pageextension 8071 "Purch Invoice Subform" extends "Purch. Invoice Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Attached to Contract Line"; Rec."Attached to Sub. Contract line")
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
                Enabled = UsageDataEnabled;

                trigger OnAction()
                var
                    UsageDataBilling: Record "Usage Data Billing";
                begin
                    UsageDataBilling.ShowForPurchaseDocuments(Rec."Document Type", Rec."Document No.", Rec."Line No.");
                end;
            }
        }
        addlast("F&unctions")
        {

            action("Assign Contract Line")
            {
                ApplicationArea = All;
                Caption = 'Assign Contract Line';
                Image = GetOrder;
                ToolTip = 'Select a corresponding Vendor Subscription Contract line.';
                Enabled = ContractLineCanBeAssigned;

                trigger OnAction()
                begin
                    Rec.AssignVendorContractLine();
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        IsConnectedToBillingLine := Rec.IsLineAttachedToBillingLine();
        ContractLineCanBeAssigned := Rec.IsContractLineAssignable();
        UsageDataEnabled := UsageDataBilling.ExistForPurchaseDocuments(Rec."Document Type", Rec."Document No.", Rec."Line No.");
    end;

    var
        ContractsGeneralMgt: Codeunit "Sub. Contracts General Mgt.";
        IsConnectedToBillingLine: Boolean;
        ContractLineCanBeAssigned: Boolean;
        UsageDataEnabled: Boolean;
}
