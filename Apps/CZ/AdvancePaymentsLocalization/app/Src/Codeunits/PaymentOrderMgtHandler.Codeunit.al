codeunit 31398 "Payment Order Mgt. Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Payment Order Management CZB", 'OnBeforeCheckPaymentOrderLineApplyToOtherEntries', '', false, false)]
    local procedure IsPurchAdvanceAppliedOnBeforeCheckPaymentOrderLineApplyToOtherEntries(var PaymentOrderLineCZB: Record "Payment Order Line CZB"; var TempErrorMessage: Record "Error Message"; var IsHandled: Boolean)
    var
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        PaymentOrderLineCZB2: Record "Payment Order Line CZB";
        PurchAdvanceAlreadyAppliedErr: Label '''%1'' %2 in ''%3'' is already applied on other payment order.', Comment = '%1 = Purch. Advance Letter No. CZZ FieldCaption; %2 = Purch. Advance Letter No. CZZ; %3 = RecordId';
    begin
        if PaymentOrderLineCZB."Purch. Advance Letter No. CZZ" = '' then
            exit;

        if IsHandled then
            exit
        else begin
            IssPaymentOrderLineCZB.SetRange(Type, PaymentOrderLineCZB.Type);
            IssPaymentOrderLineCZB.SetRange("No.", PaymentOrderLineCZB."No.");
            IssPaymentOrderLineCZB.SetRange("Purch. Advance Letter No. CZZ", PaymentOrderLineCZB."Purch. Advance Letter No. CZZ");
            IssPaymentOrderLineCZB.SetRange(Status, IssPaymentOrderLineCZB.Status::" ");
            IsHandled := not IssPaymentOrderLineCZB.IsEmpty();
        end;
        if not IsHandled then begin
            PaymentOrderLineCZB2.SetRange(Type, PaymentOrderLineCZB.Type::Vendor);
            PaymentOrderLineCZB2.SetRange("No.", PaymentOrderLineCZB."No.");
            PaymentOrderLineCZB2.SetRange("Purch. Advance Letter No. CZZ", PaymentOrderLineCZB."Purch. Advance Letter No. CZZ");
            PaymentOrderLineCZB2.SetFilter("Payment Order No.", '<>%1', PaymentOrderLineCZB."Payment Order No.");
            IsHandled := not PaymentOrderLineCZB2.IsEmpty();
        end;
        if not IsHandled then begin
            PaymentOrderLineCZB2.SetRange("Payment Order No.", PaymentOrderLineCZB."Payment Order No.");
            PaymentOrderLineCZB2.SetFilter("Line No.", '<>%1', PaymentOrderLineCZB."Line No.");
            IsHandled := not PaymentOrderLineCZB2.IsEmpty();
        end;

        if IsHandled then
            TempErrorMessage.LogMessage(
                PaymentOrderLineCZB, PaymentOrderLineCZB.FieldNo(PaymentOrderLineCZB."Purch. Advance Letter No. CZZ"), TempErrorMessage."Message Type"::Warning,
                StrSubstNo(PurchAdvanceAlreadyAppliedErr,
                    PaymentOrderLineCZB.FieldCaption(PaymentOrderLineCZB."Purch. Advance Letter No. CZZ"), PaymentOrderLineCZB."Purch. Advance Letter No. CZZ", PaymentOrderLineCZB.RecordId()));
    end;
}
