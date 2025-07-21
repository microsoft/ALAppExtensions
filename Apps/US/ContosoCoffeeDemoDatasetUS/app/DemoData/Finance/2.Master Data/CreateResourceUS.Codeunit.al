// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Projects.Resources.Resource;

codeunit 10519 "Create Resource US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeOnInsert', '', false, false)]
    local procedure OnInsertRecord(var Resource: Record Resource; var IsHandled: Boolean)
    var
        CreateResource: Codeunit "Create Resource";
    begin
        case Resource."No." of
            CreateResource.Katherine():
                ValidateRecordFields(Resource, AtlantaLbl, 77, 84.7, 45, 154, '31772', '');
            CreateResource.Lina():
                ValidateRecordFields(Resource, AtlantaLbl, 92, 101.2, 45.2973, 185, '31772', '');
            CreateResource.Marty():
                ValidateRecordFields(Resource, AtlantaLbl, 69, 75.9, 45.39568, 139, '31772', '');
            CreateResource.Terry():
                ValidateRecordFields(Resource, AtlantaLbl, 77, 84.7, 45, 154, '31772', '');
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; City: Text[30]; DirectUnitCost: Decimal; UnitCost: Decimal; ProfitPercentage: Decimal; UnitPrice: Decimal; PostCode: Code[20]; VATProdPostingGroup: Code[20])
    begin
        Resource.Validate(City, City);
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Profit %", ProfitPercentage);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
    end;

    internal procedure UpdateResourcesTaxGroup()
    var
        CreateResource: Codeunit "Create Resource";
        CreateTaxGroupUS: Codeunit "Create Tax Group US";
    begin
        UpdateTaxGroupOnResource(CreateResource.Katherine(), CreateTaxGroupUS.Labor());
        UpdateTaxGroupOnResource(CreateResource.Lina(), CreateTaxGroupUS.Labor());
        UpdateTaxGroupOnResource(CreateResource.Marty(), CreateTaxGroupUS.Labor());
        UpdateTaxGroupOnResource(CreateResource.Terry(), CreateTaxGroupUS.Labor());
    end;

    local procedure UpdateTaxGroupOnResource(ResourceNo: Code[20]; TaxGroupCode: Code[20])
    var
        Resource: Record Resource;
    begin
        Resource.Get(ResourceNo);

        Resource.Validate("Tax Group Code", TaxGroupCode);
        Resource.Modify(true);
    end;

    var
        AtlantaLbl: Label 'Atlanta', MaxLength = 30;
}
