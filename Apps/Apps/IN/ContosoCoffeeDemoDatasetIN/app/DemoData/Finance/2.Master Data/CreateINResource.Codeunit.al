// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Projects.Resources.Resource;

codeunit 19056 "Create IN Resource"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeOnInsert', '', false, false)]
    local procedure OnInsertRecord(var Resource: Record Resource; var IsHandled: Boolean)
    var
        CreateResource: Codeunit "Create Resource";
        CreateINGSTGroup: Codeunit "Create IN GST Group";
        CreateINHSNSAC: Codeunit "Create IN HSN/SAC";
    begin
        case Resource."No." of
            CreateResource.Katherine():
                ValidateRecordFields(Resource, 3500, 3850, 44.2029, 6900, 'GB-N12 5XY', CreateINGSTGroup.GSTGroup2089(), CreateINHSNSAC.HSNSACCode2089001());
            CreateResource.Lina():
                ValidateRecordFields(Resource, 4200, 4620, 44.33735, 8300, 'GB-N16 34Z', '', '');
            CreateResource.Marty():
                ValidateRecordFields(Resource, 3100, 3410, 45, 6200, 'GB-N12 5XY', '', '');
            CreateResource.Terry():
                ValidateRecordFields(Resource, 3500, 3850, 44.2029, 6900, 'GB-N12 5XY', '', '');
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; DirectUnitCost: Decimal; UnitCost: Decimal; ProfitPercentage: Decimal; UnitPrice: Decimal; PostCode: Code[20]; GSTGroupCode: Code[10]; HSNSACCode: Code[10])
    begin
        Resource.Validate("Direct Unit Cost", DirectUnitCost);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Profit %", ProfitPercentage);
        Resource.Validate("Unit Price", UnitPrice);
        Resource.Validate("Post Code", PostCode);
        Resource.Validate("GST Group Code", GSTGroupCode);
        Resource.Validate("HSN/SAC Code", HSNSACCode);
    end;
}
