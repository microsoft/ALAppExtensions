namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

pageextension 8065 "Posted Sales Cr. Memo Subform" extends "Posted Sales Cr. Memo Subform"
{
    actions
    {
        addlast("&Line")
        {
            action(ShowArchivedBillingLines)
            {
                ApplicationArea = All;
                Caption = 'Archived Billing Lines';
                Image = ViewDocumentLine;
                ToolTip = 'Show archived Billing Lines.';
                Scope = Repeater;
                Enabled = IsConnectedToContractLine;

                trigger OnAction()
                begin
                    ContractsGeneralMgt.ShowArchivedBillingLines(Rec."Contract No.", Rec."Contract Line No.", Enum::"Service Partner"::Customer, Enum::"Rec. Billing Document Type"::"Credit Memo", Rec."Document No.");
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
                    UsageDataBilling.ShowForDocuments("Usage Based Billing Doc. Type"::"Posted Credit Memo", Rec."Document No.", Rec."Line No.");
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        IsConnectedToContractLine := ContractsGeneralMgt.HasConnectionToContractLine(Rec."Contract No.", Rec."Contract Line No.");
        UsageDataEnabled := UsageDataBilling.ExistForDocuments("Usage Based Billing Doc. Type"::"Posted Credit Memo", Rec."Document No.", Rec."Line No.");
    end;

    var
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        IsConnectedToContractLine: Boolean;
        UsageDataEnabled: Boolean;
}