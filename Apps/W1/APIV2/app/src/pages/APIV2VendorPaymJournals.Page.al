page 30061 "APIV2 - Vendor Paym. Journals"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Vendor Payment Journal';
    EntitySetCaption = 'Vendor Payment Journals';
    DelayedInsert = true;
    EntityName = 'vendorPaymentJournal';
    EntitySetName = 'vendorPaymentJournals';
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
                field(balancingAccountId; BalAccountId)
                {
                    Caption = 'Balancing Account Id';
                }
                field(balancingAccountNumber; "Bal. Account No.")
                {
                    Caption = 'Balancing Account No.';
                    Editable = false;
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                part(vendorPayments; "APIV2 - Vendor Payments")
                {
                    Caption = 'Vendor Payments';
                    EntityName = 'vendorPayment';
                    EntitySetName = 'vendorPayments';
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
        "Journal Template Name" := GraphMgtJournal.GetDefaultVendorPaymentsTemplateName();
    end;

    trigger OnOpenPage()
    begin
        SetRange("Journal Template Name", GraphMgtJournal.GetDefaultVendorPaymentsTemplateName());
    end;

    var
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
}


