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
                field(id; SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field("code"; Name)
                {
                    Caption = 'code', Locked = true;
                    ShowMandatory = true;
                }
                field(displayName; Description)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(lastModifiedDateTime; "Last Modified DateTime")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
                field(balancingAccountId; BalAccountId)
                {
                    Caption = 'balancingAccountId', Locked = true;
                }
                field(balancingAccountNumber; "Bal. Account No.")
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
                SubPageLink = "Journal Batch Id" = FIELD(SystemId);
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Journal Template Name" := GraphMgtJournal.GetDefaultCustomerPaymentsTemplateName();
    end;

    trigger OnOpenPage()
    begin
        SETRANGE("Journal Template Name", GraphMgtJournal.GetDefaultCustomerPaymentsTemplateName());
    end;

    var
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
}


