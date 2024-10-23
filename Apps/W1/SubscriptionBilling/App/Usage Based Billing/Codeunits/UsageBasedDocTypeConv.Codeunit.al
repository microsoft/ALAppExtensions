namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;

codeunit 8024 "Usage Based Doc. Type Conv."
{
    Access = Internal;

    var
        ConversionNotAllowedErr: Label 'Conversion of option %1 to %2 is not possible.';

    internal procedure ConvertSalesDocTypeToUsageBasedBillingDocType(SalesDocumentType: Enum "Sales Document Type") UsageBasedBillingDocType: Enum "Usage Based Billing Doc. Type"
    begin
        case SalesDocumentType of
            SalesDocumentType::Invoice:
                UsageBasedBillingDocType := UsageBasedBillingDocType::Invoice;
            SalesDocumentType::"Credit Memo":
                UsageBasedBillingDocType := UsageBasedBillingDocType::"Credit Memo";
            else
                Error(ConversionNotAllowedErr, SalesDocumentType, UsageBasedBillingDocType);
        end;
    end;

    internal procedure ConvertPurchaseDocTypeToUsageBasedBillingDocType(PurchaseDocumentType: Enum "Purchase Document Type") UsageBasedBillingDocType: Enum "Usage Based Billing Doc. Type"
    begin
        case PurchaseDocumentType of
            PurchaseDocumentType::Invoice:
                UsageBasedBillingDocType := UsageBasedBillingDocType::Invoice;
            PurchaseDocumentType::"Credit Memo":
                UsageBasedBillingDocType := UsageBasedBillingDocType::"Credit Memo";
            else
                Error(ConversionNotAllowedErr, PurchaseDocumentType, UsageBasedBillingDocType);
        end;
    end;
}
