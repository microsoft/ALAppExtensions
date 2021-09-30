codeunit 11751 "Contact Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteRegistrationLogCZLOnAfterDelete(var Rec: Record Contact)
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        RegistrationLogMgtCZL.DeleteContactLog(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnBeforeDuplicateCheck', '', false, false)]
    local procedure RegNoOnBeforeDuplicateCheck(Contact: Record Contact; xContact: Record Contact; var IsDuplicateCheckNeeded: Boolean)
    begin
        IsDuplicateCheckNeeded := IsDuplicateCheckNeeded or
            (Contact."Registration No. CZL" <> xContact."Registration No. CZL") or
            (Contact."Tax Registration No. CZL" <> xContact."Tax Registration No. CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnAfterSetTypeForContact', '', false, false)]
    local procedure RegNoOnAfterSetTypeForContact(var Contact: Record Contact)
    begin
        case Contact.Type of
            Contact.Type::Person:
                begin
                    Contact.TestField("Registration No. CZL", '');
                    Contact.TestField("Tax Registration No. CZL", '');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnBeforeIsUpdateNeeded', '', false, false)]
    local procedure RegNoOnBeforeIsUpdateNeeded(Contact: Record Contact; xContact: Record Contact; var UpdateNeeded: Boolean)
    begin
        UpdateNeeded := UpdateNeeded or
            (Contact."Registration No. CZL" <> xContact."Registration No. CZL") or
            (Contact."Tax Registration No. CZL" <> xContact."Tax Registration No. CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustVendBank-Update", 'OnBeforeCustCopyFieldsFromCont', '', false, false)]
    local procedure SaveRegistrationNoOnBeforeCustCopyFieldsFromCont(var Customer: Record Customer)
    begin
        Customer.SaveRegistrationNoCZL();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustVendBank-Update", 'OnAfterUpdateCustomerProcedure', '', false, false)]
    local procedure RegNoLogInitOnAfterUpdateCustomer(var Customer: Record Customer)
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        if (Customer."Registration No. CZL" <> '') and (Customer.GetSavedRegistrationNoCZL() <> Customer."Registration No. CZL") then
            RegistrationLogMgtCZL.LogCustomer(Customer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustVendBank-Update", 'OnBeforeVendCopyFieldsFromCont', '', false, false)]
    local procedure SaveRegistrationNoOnBeforeVendCopyFieldsFromCont(var Vendor: Record Vendor)
    begin
        Vendor.SaveRegistrationNoCZL();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustVendBank-Update", 'OnAfterUpdateVendorProcedure', '', false, false)]
    local procedure RegNoLogInitOnAfterUpdateVendorProcedure(var Vendor: Record Vendor)
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        if (Vendor."Registration No. CZL" <> '') and (Vendor.GetSavedRegistrationNoCZL() <> Vendor."Registration No. CZL") then
            RegistrationLogMgtCZL.LogVendor(Vendor);
    end;
}
