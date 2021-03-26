codeunit 2407 "XS Create Customer Delete Json"
{
    procedure CreateCustomerDeleteJson() CustomerDataJsonTxt: Text
    var
        Handled: Boolean;
    begin
        OnBeforeCreateCustomerDeleteJson(Handled);

        CustomerDataJsonTxt := DoCreateCustomerDeleteJson(Handled);

        OnAfterCreateCustomerDeleteJson(CustomerDataJsonTxt);
    end;

    local procedure DoCreateCustomerDeleteJson(var Handled: Boolean) CustomerDataJsonTxt: Text
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        CustomerJson: JsonObject;
    begin
        if Handled then
            exit;
        JsonObjectHelper.AddValueToJObject(CustomerJson, 'ContactStatus', 'ARCHIVED');
        CustomerJson.WriteTo(CustomerDataJsonTxt);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateCustomerDeleteJson(var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateCustomerDeleteJson(var CustomerDataJsonTxt: Text);
    begin
    end;
}