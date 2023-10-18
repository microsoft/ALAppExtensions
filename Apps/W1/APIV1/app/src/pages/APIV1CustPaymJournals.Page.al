namespace Microsoft.API.V1;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Integration.Graph;

page 20013 "APIV1 - Cust. Paym. Journals"
{
    APIVersion = 'v1.0';
    Caption = 'customerPaymentJournals', Locked = true;
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
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field("code"; Rec.Name)
                {
                    Caption = 'code', Locked = true;
                    ShowMandatory = true;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(lastModifiedDateTime; Rec."Last Modified DateTime")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
                field(balancingAccountId; Rec.BalAccountId)
                {
                    Caption = 'balancingAccountId', Locked = true;
                }
                field(balancingAccountNumber; Rec."Bal. Account No.")
                {
                    Caption = 'balancingAccountNumber', Locked = true;
                    Editable = false;
                }
            }
            part(customerPayments; "APIV1 - Customer Payments")
            {
                ApplicationArea = All;
                Caption = 'customerPayments', Locked = true;
                EntityName = 'customerPayment';
                EntitySetName = 'customerPayments';
                SubPageLink = "Journal Batch Id" = field(SystemId);
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
        Rec.SETRANGE("Journal Template Name", GraphMgtJournal.GetDefaultCustomerPaymentsTemplateName());
    end;

    var
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
}



