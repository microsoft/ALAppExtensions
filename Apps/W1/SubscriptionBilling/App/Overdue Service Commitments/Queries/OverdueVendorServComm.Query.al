#if not CLEAN26
namespace Microsoft.SubscriptionBilling;

query 8001 "Overdue Vendor Serv. Comm."
{
    Caption = 'Overdue Vendor Subscription Lines';
    QueryType = Normal;
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    ObsoleteReason = 'Removed as there is no need to use queries in order to fetch Service Commitments for temporary display using buffer table "Overdue Service Commitments"';

    elements
    {
        dataitem(ServiceCommitment; "Subscription Line")
        {
            DataItemTableFilter = Partner = const(Vendor);
            column(Partner; Partner) { }
            column(ContractNo; "Subscription Contract No.") { }
            column(ServCommDescription; Description) { }
            column(NextBillingDate; "Next Billing Date") { }
            column(Quantity; Quantity) { }
            column(Price; Price) { }
            column(ServiceAmount; Amount) { }
#if not CLEAN26
            column(ItemNo; "Item No.")
            {
                ObsoleteReason = 'Replaced by field Source No.';
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';
            }
#endif
            column(SourceType; "Source Type") { }
            column(SourceNo; "Source No.") { }
            column(BillingRhythm; "Billing Rhythm") { }
            column(ServiceStartDate; "Subscription Line Start Date") { }
            column(ServiceEndDate; "Subscription Line End Date") { }
            column(ServiceObjectNo; "Subscription Header No.") { }
            column(ServiceObjectDescription; "Subscription Description") { }
            column(ServiceObjectCustomerNo; "Sub. Header Customer No.") { }
            column(Discount; "Discount %") { }
            dataitem(Contract; "Vendor Subscription Contract")
            {
                DataItemLink = "No." = ServiceCommitment."Subscription Contract No.";
                column(ContractDescription; "Description Preview") { }
                column(ContractType; "Contract Type") { }
                column(PartnerName; "Buy-from Vendor Name") { }
                dataitem(ContractLine; "Vend. Sub. Contract Line")
                {
                    DataItemLink = "Subscription Contract No." = ServiceCommitment."Subscription Contract No.", "Line No." = ServiceCommitment."Subscription Contract Line No.";
                    column(ContractLineClosed; Closed) { }
                }
            }
        }
    }
}
#endif