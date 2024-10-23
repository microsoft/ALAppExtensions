namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.Address;
using Microsoft.Sales.Customer;

codeunit 8056 "Service Object Notifications"
{
    Access = Internal;
    procedure CopySellToCustomerAddressFieldsFromServiceObject(var ModifyCustomerAddressNotification: Notification)
    var
        Customer: Record Customer;
        ServiceObject: Record "Service Object";
        UpdateAddress: Page "Update Address";
    begin
        if not ModifyCustomerAddressNotification.HasData(ServiceObject.FieldName("End-User Customer No.")) then
            exit;

        OnBeforeCopySellToCustomerAddressFieldsFromServiceObject(ModifyCustomerAddressNotification, ServiceObject);

        ServiceObject.Get(ModifyCustomerAddressNotification.GetData(ServiceObject.FieldName("No.")));
        if Customer.Get(ModifyCustomerAddressNotification.GetData(ServiceObject.FieldName("End-User Customer No."))) then begin
            UpdateAddress.SetName(Customer.Name);
            UpdateAddress.SetExistingAddress(GetCustomerFullAddress(Customer));
            UpdateAddress.SetUpdatedAddress(GetServiceObjectFullSellToAddress(ServiceObject));

            if UpdateAddress.RunModal() in [Action::OK, Action::LookupOK] then begin
                Customer.SetAddress(ServiceObject."End-User Address", ServiceObject."End-User Address 2",
                  ServiceObject."End-User Post Code", ServiceObject."End-User City", ServiceObject."End-User County",
                  ServiceObject."End-User Country/Region Code", ServiceObject."End-User Contact");
                Customer.Modify(true);
            end;
        end;
    end;

    procedure CopyBillToCustomerAddressFieldsFromServiceObject(ModifyCustomerAddressNotification: Notification)
    var
        Customer: Record Customer;
        ServiceObject: Record "Service Object";
        UpdateAddress: Page "Update Address";
    begin
        if not ModifyCustomerAddressNotification.HasData(ServiceObject.FieldName("Bill-to Customer No.")) then
            exit;

        OnBeforeCopyBillToCustomerAddressFieldsFromServiceObject(ModifyCustomerAddressNotification, ServiceObject);

        ServiceObject.Get(ModifyCustomerAddressNotification.GetData(ServiceObject.FieldName("No.")));
        if Customer.Get(ModifyCustomerAddressNotification.GetData(ServiceObject.FieldName("Bill-to Customer No."))) then begin
            UpdateAddress.SetExistingAddress(GetCustomerFullAddress(Customer));
            UpdateAddress.SetName(Customer.Name);
            UpdateAddress.SetUpdatedAddress(GetServiceObjectFullBillToAddress(ServiceObject));

            if UpdateAddress.RunModal() in [Action::OK, Action::LookupOK] then begin
                Customer.SetAddress(ServiceObject."Bill-to Address", ServiceObject."Bill-to Address 2",
                  ServiceObject."Bill-to Post Code", ServiceObject."Bill-to City", ServiceObject."Bill-to County",
                  ServiceObject."Bill-to Country/Region Code", ServiceObject."Bill-to Contact");
                Customer.Modify(true);
            end;
        end;
    end;

    local procedure GetCustomerFullAddress(Customer: Record Customer): Text
    var
        AddressArray: array[7] of Text;
    begin
        AddressArray[1] := Customer.Address;
        AddressArray[2] := Customer."Address 2";
        AddressArray[3] := Customer."Post Code";
        AddressArray[4] := Customer.City;
        AddressArray[5] := Customer.County;
        AddressArray[6] := Customer."Country/Region Code";
        AddressArray[7] := Customer.Contact;

        exit(FormatAddress(AddressArray));
    end;

    local procedure GetServiceObjectFullSellToAddress(ServiceObject: Record "Service Object"): Text
    var
        AddressArray: array[7] of Text;
    begin
        AddressArray[1] := ServiceObject."End-User Address";
        AddressArray[2] := ServiceObject."End-User Address 2";
        AddressArray[3] := ServiceObject."End-User Post Code";
        AddressArray[4] := ServiceObject."End-User City";
        AddressArray[5] := ServiceObject."End-User County";
        AddressArray[6] := ServiceObject."End-User Country/Region Code";
        AddressArray[7] := ServiceObject."End-User Contact";

        exit(FormatAddress(AddressArray));
    end;

    local procedure GetServiceObjectFullBillToAddress(ServiceObject: Record "Service Object"): Text
    var
        AddressArray: array[7] of Text;
    begin
        AddressArray[1] := ServiceObject."Bill-to Address";
        AddressArray[2] := ServiceObject."Bill-to Address 2";
        AddressArray[3] := ServiceObject."Bill-to Post Code";
        AddressArray[4] := ServiceObject."Bill-to City";
        AddressArray[5] := ServiceObject."Bill-to County";
        AddressArray[6] := ServiceObject."Bill-to Country/Region Code";
        AddressArray[7] := ServiceObject."Bill-to Contact";

        exit(FormatAddress(AddressArray));
    end;

    local procedure FormatAddress(AddressArray: array[7] of Text): Text
    var
        FullAddress: Text;
        Index: Integer;
    begin
        for Index := 1 to 7 do
            if AddressArray[Index] <> '' then
                FullAddress := FullAddress + AddressArray[Index] + ', ';

        if StrLen(FullAddress) > 0 then
            FullAddress := DelStr(FullAddress, StrLen(FullAddress) - 1);

        exit(FullAddress);
    end;

    procedure ServiceObjectHideNotificationForCurrentUser(Notification: Notification)
    var
        ServiceObject: Record "Service Object";
    begin
        ServiceObject.DontNotifyCurrentUserAgain(Notification.Id);
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCopyBillToCustomerAddressFieldsFromServiceObject(var ModifyCustomerAddressNotification: Notification; var ServiceObject: Record "Service Object")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCopySellToCustomerAddressFieldsFromServiceObject(var ModifyCustomerAddressNotification: Notification; var ServiceObject: Record "Service Object")
    begin
    end;
}

