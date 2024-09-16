namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;

pageextension 8064 "Posted Sales Invoice Subform" extends "Posted Sales Invoice Subform"
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
                    ContractsGeneralMgt.ShowArchivedBillingLines(Rec."Contract No.", Rec."Contract Line No.", Enum::"Service Partner"::Customer, Enum::"Rec. Billing Document Type"::Invoice, Rec."Document No.");
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
                    UsageDataBilling.FilterOnDocumentTypeAndDocumentNo("Usage Based Billing Doc. Type"::"Posted Invoice", Rec."Document No.");
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