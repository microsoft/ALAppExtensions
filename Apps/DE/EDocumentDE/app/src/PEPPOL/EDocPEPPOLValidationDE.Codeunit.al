namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.eServices.EDocument.Formats;
using Microsoft.Sales.Document;
using Microsoft.Sales.Peppol;

codeunit 13921 "EDoc PEPPOL Validation DE"
{
    EventSubscriberInstance = Manual;

    var
        BuyerReference: Enum "E-Document Buyer Reference";

    procedure SetBuyerReference(NewBuyerReference: Enum "E-Document Buyer Reference")
    begin
        BuyerReference := NewBuyerReference;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Validation", 'OnCheckSalesDocumentOnBeforeCheckCustomerVATRegNo', '', false, false)]
    local procedure SkipCustomerVATRegNoCheck(var IsHandled: Boolean)
    begin
        if BuyerReference = BuyerReference::"Customer Reference" then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Validation", 'OnCheckSalesDocumentOnBeforeCheckYourReference', '', false, false)]
    local procedure SkipCheckOnCheckSalesDocumentOnBeforeCheckYourReference(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Validation", 'OnAfterCheckSalesDocument', '', false, false)]
    local procedure OnAfterCheckSalesDocument(SalesHeader: Record "Sales Header")
    begin
        SalesHeader.TestField("Sell-to E-Mail");
    end;
}
