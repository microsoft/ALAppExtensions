codeunit 31423 "Notification Handler CZB"
{
    var
        PaymentOrderTxt: Label 'Payment Order';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", 'OnGetDocumentTypeAndNumber', '', false, false)]
    local procedure GetDocumentTypeAndNumberFromPaymentOrderOnGetDocumentTypeAndNumber(var RecRef: RecordRef; var DocumentType: Text; var DocumentNo: Text; var IsHandled: Boolean)
    var
        FieldRef: FieldRef;
    begin
        if IsHandled then
            exit;

        IsHandled := true;
        case RecRef.Number of
            Database::"Payment Order Header CZB":
                begin
                    DocumentType := PaymentOrderTxt;
                    FieldRef := RecRef.Field(1);
                    DocumentNo := Format(FieldRef.Value);
                end;
            else
                IsHandled := false;
        end;
    end;
}