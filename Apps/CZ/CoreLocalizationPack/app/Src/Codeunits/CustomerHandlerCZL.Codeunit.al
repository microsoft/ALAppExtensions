// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

using Microsoft.Finance.Registration;

codeunit 11752 "Customer Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', false, false)]
    local procedure InitValueOnAfterInsertEvent(var Rec: Record Customer)
    begin
        if not Rec."Allow Multiple Posting Groups" then begin
            Rec."Allow Multiple Posting Groups" := true;
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteRegistrationLogCZLOnAfterDelete(var Rec: Record Customer)
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        RegistrationLogMgtCZL.DeleteCustomerLog(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Customer Posting Group', false, false)]
    local procedure CheckChangeCustomerPostingGroupOnAfterCustomerPostingGroupValidate(var Rec: Record Customer)
    begin
        Rec.CheckOpenCustomerLedgerEntriesCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeIsContactUpdateNeeded', '', false, false)]
    local procedure CheckChangeOnBeforeIsContactUpdateNeeded(Customer: Record Customer; xCustomer: Record Customer; var UpdateNeeded: Boolean)
    begin
        UpdateNeeded := UpdateNeeded or
            (Customer."Registration Number" <> xCustomer."Registration Number") or
            (Customer."Tax Registration No. CZL" <> xCustomer."Tax Registration No. CZL");
    end;
}
