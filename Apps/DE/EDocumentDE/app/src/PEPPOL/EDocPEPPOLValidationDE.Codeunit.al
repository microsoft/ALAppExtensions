namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.Sales.Document;
using Microsoft.Sales.Peppol;

codeunit 13921 "EDoc PEPPOL Validation DE"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Validation", 'OnCheckSalesDocumentOnBeforeCheckYourReference', '', false, false)]
    local procedure SkipCheckOnCheckSalesDocumentOnBeforeCheckYourReference(SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"PEPPOL Validation", 'OnAfterCheckSalesDocument', '', false, false)]
    local procedure OnAfterCheckSalesDocument(SalesHeader: Record "Sales Header")
    begin
        SalesHeader.TestField("Sell-to E-Mail");
    end;
}
