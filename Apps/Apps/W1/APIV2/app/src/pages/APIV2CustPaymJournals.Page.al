namespace Microsoft.API.V2;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Integration.Graph;

page 30013 "APIV2 - Cust. Paym. Journals"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Customer Payment Journal';
    EntitySetCaption = 'Customer Payment Journals';
    DelayedInsert = true;
    EntityName = 'customerPaymentJournal';
    EntitySetName = 'customerPaymentJournals';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Gen. Journal Batch";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Rec.Name)
                {
                    Caption = 'Code';
                    ShowMandatory = true;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'Display Name';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                field(balancingAccountId; Rec.BalAccountId)
                {
                    Caption = 'Balancing Account Id';
                }
                field(balancingAccountNumber; Rec."Bal. Account No.")
                {
                    Caption = 'Balancing Account No.';
                    Editable = false;
                }
                part(customerPayments; "APIV2 - Customer Payments")
                {
                    Caption = 'Customer Payments';
                    EntityName = 'customerPayment';
                    EntitySetName = 'customerPayments';
                    SubPageLink = "Journal Batch Id" = field(SystemId);
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Journal Template Name" := GraphMgtJournal.GetDefaultCustomerPaymentsTemplateName();
    end;

    trigger OnOpenPage()
    begin
        Rec.SetRange("Journal Template Name", GraphMgtJournal.GetDefaultCustomerPaymentsTemplateName());
    end;

    var
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
}


