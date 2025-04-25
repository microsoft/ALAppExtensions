// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Projects.Resources.Resource;

codeunit 31192 "Create Resource CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertResource(var Rec: Record Resource)
    var
        CreateCurrencyExRateCZ: Codeunit "Create Currency Ex. Rate CZ";
        CreateResource: Codeunit "Create Resource";
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
    begin
        case Rec."No." of
            CreateResource.Katherine(),
            CreateResource.Terry(),
            CreateResource.Marty(),
            CreateResource.Lina():
                ValidateRecordFields(Rec, CreateVatPostingGroupsCZ.VAT21S(),
                    Rec."Unit Cost" / CreateCurrencyExRateCZ.GetLocalCurrencyFactor(),
                    Rec."Unit Price" / CreateCurrencyExRateCZ.GetLocalCurrencyFactor());
        end;
    end;

    local procedure ValidateRecordFields(var Resource: Record Resource; VATProdPostingGroup: Code[20]; UnitCost: Decimal; UnitPrice: Decimal)
    begin
        Resource.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Unit Price", UnitPrice);
    end;
}
