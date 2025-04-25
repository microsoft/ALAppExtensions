// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Finance.Dimension;
using Microsoft.DemoData.Finance;
using Microsoft.Purchases.Vendor;

codeunit 19017 "Create IN Purch. Dim. Value"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", OnBeforeInsertEvent, '', false, false)]
    local procedure OnBeforeInsertVendorDefaultDimensions(var Rec: Record "Default Dimension")
    var
        CreateVendor: Codeunit "Create Vendor";
        CreateDimension: Codeunit "Create Dimension";
        CreateDimensionValue: Codeunit "Create Dimension Value";
    begin
        if (Rec."Table ID" = Database::Vendor) then
            if Rec."Dimension Code" = CreateDimension.AreaDimension() then
                case Rec."No." of
                    CreateVendor.DomesticFirstUp(),
                    CreateVendor.DomesticWorldImporter(),
                        CreateVendor.DomesticNodPublisher():
                        ValidateRecordFields(Rec, CreateDimensionValue.EuropeNorthEUArea());
                end;
    end;

    local procedure ValidateRecordFields(var DefaultDimension: Record "Default Dimension"; DimensionValueCode: Code[20])
    begin
        DefaultDimension.Validate("Dimension Value Code", DimensionValueCode);
    end;
}
