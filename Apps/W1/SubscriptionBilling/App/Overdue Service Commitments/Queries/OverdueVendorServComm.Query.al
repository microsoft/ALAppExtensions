#if not CLEAN26
namespace Microsoft.SubscriptionBilling;

query 8001 "Overdue Vendor Serv. Comm."
{
    Caption = 'Overdue Vendor Service Commitments';
    QueryType = Normal;
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';
    ObsoleteReason = 'Removed as there is no need to use queries in order to fetch Service Commitments for temporary display using buffer table "Overdue Service Commitments"';

    elements
    {
        dataitem(ServiceCommitment; "Service Commitment")
        {
            DataItemTableFilter = Partner = const(Vendor);
            column(Partner; Partner) { }
            column(ContractNo; "Contract No.") { }
            column(ServCommDescription; Description) { }
            column(NextBillingDate; "Next Billing Date") { }
            column(Quantity; "Quantity Decimal") { }
            column(Price; Price) { }
            column(ServiceAmount; "Service Amount") { }
            column(ItemNo; "Item No.") { }
            column(BillingRhythm; "Billing Rhythm") { }
            column(ServiceStartDate; "Service Start Date") { }
            column(ServiceEndDate; "Service End Date") { }
            column(ServiceObjectNo; "Service Object No.") { }
            column(ServiceObjectDescription; "Service Object Description") { }
            column(ServiceObjectCustomerNo; "Service Object Customer No.") { }
            column(Discount; "Discount %") { }
            dataitem(Contract; "Vendor Contract")
            {
                DataItemLink = "No." = ServiceCommitment."Contract No.";
                column(ContractDescription; "Description Preview") { }
                column(ContractType; "Contract Type") { }
                column(PartnerName; "Buy-from Vendor Name") { }
                dataitem(ContractLine; "Vendor Contract Line")
                {
                    DataItemLink = "Contract No." = ServiceCommitment."Contract No.", "Line No." = ServiceCommitment."Contract Line No.";
                    column(ContractLineClosed; Closed) { }
                }
            }
        }
    }
}
#endif