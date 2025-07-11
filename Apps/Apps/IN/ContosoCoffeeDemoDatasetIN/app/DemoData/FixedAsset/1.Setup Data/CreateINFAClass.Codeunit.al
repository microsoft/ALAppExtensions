// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.FixedAssets.Setup;

codeunit 19061 "Create IN FA Class"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"FA Class", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertFAClass(var Rec: Record "FA Class")
    var
        CreateFAClass: Codeunit "Create FA Class";
    begin
        case Rec.Code of
            CreateFAClass.FinancialClass():
                Rec.Validate(Name, FinancialLbl);
            CreateFAClass.InTangibleClass():
                Rec.Validate(Name, InTangibleLbl);
            CreateFAClass.TangibleClass():
                Rec.Validate(Name, TangibleLbl);
        end;
    end;

    var
        FinancialLbl: Label 'Financial Fixed Assets', MaxLength = 50;
        InTangibleLbl: Label 'Intangible Fixed Assets', MaxLength = 50;
        TangibleLbl: Label 'Tangible Fixed Assets', MaxLength = 50;
}
