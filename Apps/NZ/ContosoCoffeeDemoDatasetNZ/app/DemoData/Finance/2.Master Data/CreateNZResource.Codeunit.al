// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Projects.Resources.Resource;

codeunit 17125 "Create NZ Resource"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateResource: Codeunit "Create Resource";
    begin
        case Rec."No." of
            CreateResource.Katherine(),
            CreateResource.Terry():
                ValidateRecordFields(Rec, AucklandPostmasterCityLbl, PostCode1030Lbl, 170, 187, 340, 45);
            CreateResource.Lina():
                ValidateRecordFields(Rec, AucklandCityLbl, PostCode1001Lbl, 210, 231, 410, 43.65854);
            CreateResource.Marty():
                ValidateRecordFields(Rec, AucklandPostmasterCityLbl, PostCode1030Lbl, 160, 176, 310, 43.22581);
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; PostCode: Code[20]; DirectUnitCost: Decimal; UnitCost: Decimal; UnitPrice: Decimal; ProfitPercantage: Decimal)
    begin
        Resource.Validate(City, City);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("Profit %", ProfitPercantage);
    end;

    var
        AucklandPostmasterCityLbl: Label 'Auckland Postmaster', MaxLength = 30, Locked = true;
        AucklandCityLbl: Label 'Auckland', MaxLength = 30, Locked = true;
        PostCode1030Lbl: Label '1030', MaxLength = 20;
        PostCode1001Lbl: Label '1001', MaxLength = 20;
}
