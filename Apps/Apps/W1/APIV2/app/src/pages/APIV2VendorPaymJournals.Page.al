namespace Microsoft.API.V2;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Integration.Graph;

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
                field(balancingAccountId; Rec.BalAccountId)
                {
                    Caption = 'Balancing Account Id';
                }
                field(balancingAccountNumber; Rec."Bal. Account No.")
                {
                    Caption = 'Balancing Account No.';
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                part(vendorPayments; "APIV2 - Vendor Payments")
                {
                    Caption = 'Vendor Payments';
                    EntityName = 'vendorPayment';
                    EntitySetName = 'vendorPayments';
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
        Rec."Journal Template Name" := GraphMgtJournal.GetDefaultVendorPaymentsTemplateName();
    end;

    trigger OnOpenPage()
    begin
        Rec.SetRange("Journal Template Name", GraphMgtJournal.GetDefaultVendorPaymentsTemplateName());
    end;

    var
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
}


