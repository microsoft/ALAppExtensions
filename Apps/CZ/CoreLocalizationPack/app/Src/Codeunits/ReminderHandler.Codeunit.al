codeunit 11749 "Reminder Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Reminder Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure UpdateRegNoOnAfterCustomerNoValidate(var Rec: Record "Reminder Header")
    var
        Customer: Record Customer;
    begin
        if Rec."Customer No." <> '' then begin
            Customer.Get(Rec."Customer No.");
            Rec."Registration No. CZL" := Customer."Registration No. CZL";
            Rec."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
        end;
    end;
}
