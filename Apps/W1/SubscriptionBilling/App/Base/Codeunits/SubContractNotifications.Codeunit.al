namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;
using Microsoft.Foundation.Address;
using Microsoft.Purchases.Vendor;

codeunit 8053 "Sub. Contract Notifications"
{
    trigger OnRun()
    begin
    end;

    internal procedure CopyEndUserCustomerAddressFieldsFromCustomerContract(var ModifyCustomerAddressNotification: Notification)
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        UpdateAddress: Page "Update Address";
    begin
        if not ModifyCustomerAddressNotification.HasData(CustomerContract.FieldName("Sell-to Customer No.")) then
            exit;

        OnBeforeCopyEndUserCustomerAddressFieldsFromCustomerSubscriptionContract(ModifyCustomerAddressNotification, CustomerContract);

        CustomerContract.Get(ModifyCustomerAddressNotification.GetData(CustomerContract.FieldName("No.")));
        if Customer.Get(ModifyCustomerAddressNotification.GetData(CustomerContract.FieldName("Sell-to Customer No."))) then begin
            UpdateAddress.SetName(Customer.Name);
            UpdateAddress.SetExistingAddress(GetCustomerFullAddress(Customer));
            UpdateAddress.SetUpdatedAddress(GetCustomerContractFullEndUserAddress(CustomerContract));

            if UpdateAddress.RunModal() in [Action::OK, Action::LookupOK] then begin
                Customer.SetAddress(CustomerContract."Sell-to Address", CustomerContract."Sell-to Address 2",
                  CustomerContract."Sell-to Post Code", CustomerContract."Sell-to City", CustomerContract."Sell-to County",
                  CustomerContract."Sell-to Country/Region Code", CustomerContract."Sell-to Contact");
                Customer.Modify(true);
            end;
        end;
    end;

    internal procedure CopyBillToCustomerAddressFieldsFromCustomerContract(ModifyCustomerAddressNotification: Notification)
    var
        Customer: Record Customer;
        CustomerContract: Record "Customer Subscription Contract";
        UpdateAddress: Page "Update Address";
    begin
        if not ModifyCustomerAddressNotification.HasData(CustomerContract.FieldName("Bill-to Customer No.")) then
            exit;

        OnBeforeCopyBillToCustomerAddressFieldsFromCustomerSubscriptionContract(ModifyCustomerAddressNotification, CustomerContract);

        CustomerContract.Get(ModifyCustomerAddressNotification.GetData(CustomerContract.FieldName("No.")));
        if Customer.Get(ModifyCustomerAddressNotification.GetData(CustomerContract.FieldName("Bill-to Customer No."))) then begin
            UpdateAddress.SetExistingAddress(GetCustomerFullAddress(Customer));
            UpdateAddress.SetName(Customer.Name);
            UpdateAddress.SetUpdatedAddress(GetCustomerContractFullBillToAddress(CustomerContract));

            if UpdateAddress.RunModal() in [Action::OK, Action::LookupOK] then begin
                Customer.SetAddress(CustomerContract."Bill-to Address", CustomerContract."Bill-to Address 2",
                  CustomerContract."Bill-to Post Code", CustomerContract."Bill-to City", CustomerContract."Bill-to County",
                  CustomerContract."Bill-to Country/Region Code", CustomerContract."Bill-to Contact");
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

    local procedure GetCustomerContractFullEndUserAddress(CustomerContract: Record "Customer Subscription Contract"): Text
    var
        AddressArray: array[7] of Text;
    begin
        AddressArray[1] := CustomerContract."Sell-to Address";
        AddressArray[2] := CustomerContract."Sell-to Address 2";
        AddressArray[3] := CustomerContract."Sell-to Post Code";
        AddressArray[4] := CustomerContract."Sell-to City";
        AddressArray[5] := CustomerContract."Sell-to County";
        AddressArray[6] := CustomerContract."Sell-to Country/Region Code";
        AddressArray[7] := CustomerContract."Sell-to Contact";

        exit(FormatAddress(AddressArray));
    end;

    local procedure GetCustomerContractFullBillToAddress(CustomerContract: Record "Customer Subscription Contract"): Text
    var
        AddressArray: array[7] of Text;
    begin
        AddressArray[1] := CustomerContract."Bill-to Address";
        AddressArray[2] := CustomerContract."Bill-to Address 2";
        AddressArray[3] := CustomerContract."Bill-to Post Code";
        AddressArray[4] := CustomerContract."Bill-to City";
        AddressArray[5] := CustomerContract."Bill-to County";
        AddressArray[6] := CustomerContract."Bill-to Country/Region Code";
        AddressArray[7] := CustomerContract."Bill-to Contact";

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

    internal procedure CustomerContractHideNotificationForCurrentUser(Notification: Notification)
    var
        CustomerContract: Record "Customer Subscription Contract";
    begin
        CustomerContract.DontNotifyCurrentUserAgain(Notification.Id);
    end;

    internal procedure VendorContractHideNotificationForCurrentUser(Notification: Notification)
    var
        VendorContract: Record "Vendor Subscription Contract";
    begin
        VendorContract.DontNotifyCurrentUserAgain(Notification.Id);
    end;

    internal procedure CopyBuyFromVendorAddressFieldsFromVendorContract(var ModifyVendorAddressNotification: Notification)
    var
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Subscription Contract";
        UpdateAddress: Page "Update Address";
    begin
        if not ModifyVendorAddressNotification.HasData(VendorContract.FieldName("Buy-from Vendor No.")) then
            exit;

        OnBeforeCopyBuyFromVendorAddressFieldsFromVendorSubscriptionContract(ModifyVendorAddressNotification, VendorContract);

        VendorContract.Get(ModifyVendorAddressNotification.GetData(VendorContract.FieldName("No.")));
        if Vendor.Get(ModifyVendorAddressNotification.GetData(VendorContract.FieldName("Buy-from Vendor No."))) then begin
            UpdateAddress.SetName(Vendor.Name);
            UpdateAddress.SetExistingAddress(GetVendorFullAddress(Vendor));
            UpdateAddress.SetUpdatedAddress(GetPurchaseHeaderFullBuyFromAddress(VendorContract));

            if UpdateAddress.RunModal() in [Action::OK, Action::LookupOK] then begin
                Vendor.SetAddress(VendorContract."Buy-from Address", VendorContract."Buy-from Address 2",
                  VendorContract."Buy-from Post Code", VendorContract."Buy-from City", VendorContract."Buy-from County",
                  VendorContract."Buy-from Country/Region Code", VendorContract."Buy-from Contact");
                Vendor.Modify(true);
            end;
        end;
    end;

    internal procedure CopyPayToVendorAddressFieldsFromVendorContract(ModifyVendorAddressNotification: Notification)
    var
        Vendor: Record Vendor;
        VendorContract: Record "Vendor Subscription Contract";
        UpdateAddress: Page "Update Address";
    begin
        if not ModifyVendorAddressNotification.HasData(VendorContract.FieldName("Pay-to Vendor No.")) then
            exit;

        OnBeforeCopyPayToVendorAddressFieldsFromVendorSubscriptionContract(ModifyVendorAddressNotification, VendorContract);


        VendorContract.Get(ModifyVendorAddressNotification.GetData(VendorContract.FieldName("No.")));
        if Vendor.Get(ModifyVendorAddressNotification.GetData(VendorContract.FieldName("Pay-to Vendor No."))) then begin
            UpdateAddress.SetName(Vendor.Name);
            UpdateAddress.SetUpdatedAddress(GetPurchaseHeaderFullPayToAddress(VendorContract));
            UpdateAddress.SetExistingAddress(GetVendorFullAddress(Vendor));

            if UpdateAddress.RunModal() in [Action::OK, Action::LookupOK] then begin
                Vendor.SetAddress(VendorContract."Pay-to Address", VendorContract."Pay-to Address 2",
                  VendorContract."Pay-to Post Code", VendorContract."Pay-to City", VendorContract."Pay-to County",
                  VendorContract."Pay-to Country/Region Code", VendorContract."Pay-to Contact");
                Vendor.Modify(true);
            end;
        end;
    end;

    local procedure GetVendorFullAddress(Vendor: Record Vendor): Text
    var
        AddressArray: array[7] of Text;
    begin
        AddressArray[1] := Vendor.Address;
        AddressArray[2] := Vendor."Address 2";
        AddressArray[3] := Vendor."Post Code";
        AddressArray[4] := Vendor.City;
        AddressArray[5] := Vendor.County;
        AddressArray[6] := Vendor."Country/Region Code";
        AddressArray[7] := Vendor.Contact;

        exit(FormatAddress(AddressArray));
    end;

    local procedure GetPurchaseHeaderFullBuyFromAddress(VendorContract: Record "Vendor Subscription Contract"): Text
    var
        AddressArray: array[7] of Text;
    begin
        AddressArray[1] := VendorContract."Buy-from Address";
        AddressArray[2] := VendorContract."Buy-from Address 2";
        AddressArray[3] := VendorContract."Buy-from Post Code";
        AddressArray[4] := VendorContract."Buy-from City";
        AddressArray[5] := VendorContract."Buy-from County";
        AddressArray[6] := VendorContract."Buy-from Country/Region Code";
        AddressArray[7] := VendorContract."Buy-from Contact";

        exit(FormatAddress(AddressArray));
    end;

    local procedure GetPurchaseHeaderFullPayToAddress(VendorContract: Record "Vendor Subscription Contract"): Text
    var
        AddressArray: array[7] of Text;
    begin
        AddressArray[1] := VendorContract."Pay-to Address";
        AddressArray[2] := VendorContract."Pay-to Address 2";
        AddressArray[3] := VendorContract."Pay-to Post Code";
        AddressArray[4] := VendorContract."Pay-to City";
        AddressArray[5] := VendorContract."Pay-to County";
        AddressArray[6] := VendorContract."Pay-to Country/Region Code";
        AddressArray[7] := VendorContract."Pay-to Contact";

        exit(FormatAddress(AddressArray));
    end;

    internal procedure ShowServiceObjects(var ShowServiceObjectsNotification: Notification)
    var
        ServiceObject: Record "Subscription Header";
    begin
        if not ShowServiceObjectsNotification.HasData(GetDataNameServiceObjectNoFilter()) then
            exit;

        ServiceObject.Reset();
        ServiceObject.SetFilter("No.", ShowServiceObjectsNotification.GetData(GetDataNameServiceObjectNoFilter()));
        case ServiceObject.Count of
            0:
                exit;
            1:
                Page.Run(Page::"Service Object", ServiceObject)
            else
                Page.Run(Page::"Service Objects", ServiceObject);
        end;
    end;

    internal procedure GetDataNameServiceObjectNoFilter(): Text
    begin
        exit('ServiceObjectNoFilter');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyBillToCustomerAddressFieldsFromCustomerSubscriptionContract(var ModifyCustomerAddressNotification: Notification; var CustomerSubscriptionContract: Record "Customer Subscription Contract")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyEndUserCustomerAddressFieldsFromCustomerSubscriptionContract(var ModifyCustomerAddressNotification: Notification; var CustomerSubscriptionContract: Record "Customer Subscription Contract")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyBuyFromVendorAddressFieldsFromVendorSubscriptionContract(var ModifyVendorAddressNotification: Notification; var VendorSubscriptionContract: Record "Vendor Subscription Contract")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCopyPayToVendorAddressFieldsFromVendorSubscriptionContract(var ModifyVendorAddressNotification: Notification; var VendorSubscriptionContract: Record "Vendor Subscription Contract")
    begin
    end;
}

