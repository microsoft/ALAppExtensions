// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Customer;
using Microsoft.DemoTool;

codeunit 19057 "Create IN Ship-to Address"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertShiptoAddress(var Rec: Record "Ship-to Address")
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateCustomer: Codeunit "Create Customer";
        CreateShiptoAddress: Codeunit "Create Ship-to Address";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        if (Rec."Customer No." = CreateCustomer.DomesticAdatumCorporation()) then
            case Rec.Code of
                CreateShiptoAddress.Cheltenham():
                    Rec.Validate("Post Code", 'GB-GL50 1TY');
                CreateShiptoAddress.London():
                    Rec.Validate("Post Code", 'GB-W2 6BD');
            end;

        if Rec."Customer No." = CreateCustomer.DomesticTreyResearch() then
            case Rec.Code of
                CreateShiptoAddress.Fleet():
                    Rec.Validate("Post Code", 'GB-GU52 8DY');
                CreateShiptoAddress.TWYCross():
                    Rec.Validate("Post Code", 'GB-CV9 3QN');
            end;
    end;
}
