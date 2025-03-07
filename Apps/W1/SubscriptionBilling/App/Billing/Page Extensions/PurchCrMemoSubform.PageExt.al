namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Document;

pageextension 8072 "Purch Cr. Memo Subform" extends "Purch. Cr. Memo Subform"
{
    actions
    {
        addlast("&Line")
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
    }

    trigger OnAfterGetCurrRecord()
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        IsConnectedToBillingLine := Rec.IsLineAttachedToBillingLine();
        UsageDataEnabled := UsageDataBilling.ExistForPurchaseDocuments(Rec."Document Type", Rec."Document No.", Rec."Line No.");
    end;

    var
        ContractsGeneralMgt: Codeunit "Sub. Contracts General Mgt.";
        IsConnectedToBillingLine: Boolean;
        UsageDataEnabled: Boolean;
}
