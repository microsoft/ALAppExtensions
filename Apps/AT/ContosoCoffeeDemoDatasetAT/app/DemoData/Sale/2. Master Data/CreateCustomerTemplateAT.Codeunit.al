// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Customer;
using Microsoft.DemoTool;

codeunit 11176 "Create Customer Template AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomerTemplate(var Rec: Record "Customer Templ.")
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateCustomerTemplate: Codeunit "Create Customer Template";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        case Rec.Code of
            CreateCustomerTemplate.CustomerCompany(), CreateCustomerTemplate.CustomerPerson():
                Rec.Validate("Country/Region Code", ContosoCoffeeDemoDataSetup."Country/Region Code");
        end;
    end;
}
