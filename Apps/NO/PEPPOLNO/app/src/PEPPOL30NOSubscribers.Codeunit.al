// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol;

using Microsoft.Foundation.Company;

codeunit 37351 "PEPPOL30 NO Subscribers"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", OnAfterInitElectronicFormats, '', false, false)]
    local procedure CompanyInitialize_OnAfterInitElectronicFormats()
    var
        PEPPOL30NOInstall: Codeunit "PEPPOL30 NO Install";
    begin
        PEPPOL30NOInstall.CreateElectronicDocumentFormats();
    end;

    [EventSubscriber(ObjectType::Table, Database::"PEPPOL 3.0 Setup", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertPEPPOL30Setup(var Rec: Record "PEPPOL 3.0 Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        Rec."PEPPOL 3.0 Sales Format" := Rec."PEPPOL 3.0 Sales Format"::"PEPPOL 3.0 - Sales NO";
        Rec."PEPPOL 3.0 Service Format" := Rec."PEPPOL 3.0 Service Format"::"PEPPOL 3.0 - Service NO";
        Rec.Modify();
    end;
}
