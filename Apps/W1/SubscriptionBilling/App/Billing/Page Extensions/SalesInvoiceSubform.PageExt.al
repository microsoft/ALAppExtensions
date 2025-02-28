namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;

pageextension 8062 "Sales Invoice Subform" extends "Sales Invoice Subform"
{

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
                ToolTip = 'Shows related usage data.';
                Enabled = UsageDataEnabled;

                trigger OnAction()
                var
                    UsageDataBilling: Record "Usage Data Billing";
                begin
                    UsageDataBilling.ShowForSalesDocuments(Rec."Document Type", Rec."Document No.", Rec."Line No.");
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        Rec.InitCachedVar();
        IsConnectedToBillingLine := Rec.IsLineAttachedToBillingLine();
        UsageDataEnabled := UsageDataBilling.ExistForSalesDocuments(Rec."Document Type", Rec."Document No.", Rec."Line No.");
    end;

    var
        ContractsGeneralMgt: Codeunit "Sub. Contracts General Mgt.";
        IsConnectedToBillingLine: Boolean;
        UsageDataEnabled: Boolean;
}