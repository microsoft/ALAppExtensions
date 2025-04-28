// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Finance.Dimension;
using Microsoft.DemoData.Finance;
using Microsoft.Sales.Customer;

codeunit 11595 "Create CH Sales Dim. Value"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", OnBeforeInsertEvent, '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Default Dimension")
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateDimension: Codeunit "Create Dimension";
        CreateDimensionValue: Codeunit "Create Dimension Value";
    begin
        if (Rec."Table ID" = Database::Customer) and (Rec."Dimension Code" = CreateDimension.AreaDimension()) then
            case Rec."No." of
                CreateCustomer.DomesticAdatumCorporation(),
                CreateCustomer.DomesticTreyResearch(),
                CreateCustomer.DomesticRelecloud():
                    ValidateRecordFields(Rec, CreateDimensionValue.EuropeNorthEUArea(), Enum::"Default Dimension Value Posting Type"::"Code Mandatory")
            end;
    end;

    local procedure ValidateRecordFields(var DefaultDimension: Record "Default Dimension"; DimensionValueCode: Code[20]; ValuePosting: Enum "Default Dimension Value Posting Type")
    begin
        DefaultDimension.Validate("Dimension Value Code", DimensionValueCode);
        DefaultDimension.Validate("Value Posting", ValuePosting);
    end;
}
