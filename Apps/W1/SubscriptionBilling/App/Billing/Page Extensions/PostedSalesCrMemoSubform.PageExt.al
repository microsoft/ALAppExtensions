namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

pageextension 8065 "Posted Sales Cr. Memo Subform" extends "Posted Sales Cr. Memo Subform"
{
    actions
    {
        addlast(Processing)
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

                trigger OnAction()
                var
                    UsageDataBilling: Record "Usage Data Billing";
                begin
                    UsageDataBilling.FilterOnDocumentTypeAndDocumentNo("Usage Based Billing Doc. Type"::"Posted Credit Memo", Rec."Document No.");
                    UsageDataBilling.SetRange("Document Line No.", Rec."Line No.");
                    Page.RunModal(Page::"Usage Data Billings", UsageDataBilling);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsConnectedToContractLine := ContractsGeneralMgt.HasConnectionToContractLine(Rec."Contract No.", Rec."Contract Line No.");
    end;

    var
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        IsConnectedToContractLine: Boolean;
}