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
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Name)
                {
                    Caption = 'Code';
                    ShowMandatory = true;
                }
                field(displayName; Description)
                {
                    Caption = 'Display Name';
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                field(balancingAccountId; BalAccountId)
                {
                    Caption = 'Balancing Account Id';
                }
                field(balancingAccountNumber; "Bal. Account No.")
                {
                    Caption = 'Balancing Account No.';
                    Editable = false;
                }
                part(customerPayments; "APIV2 - Customer Payments")
                {
                    Caption = 'Customer Payments';
                    EntityName = 'customerPayment';
                    EntitySetName = 'customerPayments';
                    SubPageLink = "Journal Batch Id" = Field(SystemId);
                }
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
        SetRange("Journal Template Name", GraphMgtJournal.GetDefaultCustomerPaymentsTemplateName());
    end;

    var
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
}


