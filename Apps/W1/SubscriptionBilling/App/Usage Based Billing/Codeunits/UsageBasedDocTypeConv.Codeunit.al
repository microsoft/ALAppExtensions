namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;

codeunit 8024 "Usage Based Doc. Type Conv."
{
    Access = Internal;

    var
        ConversionNotAllowedErr: Label 'Conversion of option %1 to %2 is not possible.', Comment = '%1=Source Option, %2=Target Option';

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

    internal procedure ConvertRecurringBillingDocTypeToUsageBasedBillingDocType(RecurringBillingDocumentType: Enum "Rec. Billing Document Type") UsageBasedBillingDocType: Enum "Usage Based Billing Doc. Type"
    begin
        case RecurringBillingDocumentType of
            RecurringBillingDocumentType::None:
                UsageBasedBillingDocType := UsageBasedBillingDocType::None;
            RecurringBillingDocumentType::Invoice:
                UsageBasedBillingDocType := UsageBasedBillingDocType::Invoice;
            RecurringBillingDocumentType::"Credit Memo":
                UsageBasedBillingDocType := UsageBasedBillingDocType::"Credit Memo";
            else
                Error(ConversionNotAllowedErr, RecurringBillingDocumentType, UsageBasedBillingDocType);
        end;
    end;
}
