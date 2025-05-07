// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Projects.Resources.Resource;

codeunit 27065 "Create CA Resource"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateResource: Codeunit "Create Resource";
        CreateCATaxGroup: Codeunit "Create CA Tax Group";
    begin
        UpdateTaxGroupOnResource(CreateResource.Katherine(), CreateCATaxGroup.Labor());
        UpdateTaxGroupOnResource(CreateResource.Lina(), CreateCATaxGroup.Labor());
        UpdateTaxGroupOnResource(CreateResource.Marty(), CreateCATaxGroup.Labor());
        UpdateTaxGroupOnResource(CreateResource.Terry(), CreateCATaxGroup.Labor());
    end;

    local procedure UpdateTaxGroupOnResource(ResourceNo: Code[20]; TaxGroupCode: Code[20])
    var
        Resource: Record Resource;
    begin
        Resource.Get(ResourceNo);

        Resource.Validate("Tax Group Code", TaxGroupCode);
        Resource.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeOnInsert', '', false, false)]
    local procedure OnInsertRecord(var Resource: Record Resource; var IsHandled: Boolean)
    var
        CreateResource: Codeunit "Create Resource";
    begin
        case Resource."No." of
            CreateResource.Katherine(),
            CreateResource.Terry():
                ValidateRecordFields(Resource, TorontoLbl, 116, 127.6, 232, 154, 'M5K 1E7', '', '');
            CreateResource.Lina():
                ValidateRecordFields(Resource, LondonLbl, 139, 152.9, 278, 185, 'GB-N16 34Z', '', '');
            CreateResource.Marty():
                ValidateRecordFields(Resource, TorontoLbl, 104, 114.4, 208, 139, 'M5K 1E7', '', '');
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; DirectUnitCost: Decimal; UnitCost: Decimal; UnitPrice: Decimal; ProfitPercentage: Decimal; PostCode: Code[20]; County: Code[30]; CountryRegionCode: Code[10])
    begin
        Resource.Validate("Country/Region Code", CountryRegionCode);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate(County, County);
        Resource.Validate(City, City);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Profit %", ProfitPercentage);
        Resource.Validate("Unit Price", UnitPrice);
    end;

    var
        TorontoLbl: Label 'Toronto', MaxLength = 30;
        LondonLbl: Label 'London', MaxLength = 30;
}
