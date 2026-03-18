// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol;

using Microsoft.Foundation.Company;

codeunit 37353 "PEPPOL30 NA Subscribers"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", OnAfterInitElectronicFormats, '', false, false)]
    local procedure CompanyInitialize_OnAfterInitElectronicFormats()
    var
        PEPPOL30NAInstall: Codeunit "PEPPOL30 NA Install";
    begin
        PEPPOL30NAInstall.CreateElectronicDocumentFormats();
    end;

    [EventSubscriber(ObjectType::Table, Database::"PEPPOL 3.0 Setup", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertPEPPOL30Setup(var Rec: Record "PEPPOL 3.0 Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        Rec."PEPPOL 3.0 Sales Format" := Rec."PEPPOL 3.0 Sales Format"::"PEPPOL 3.0 - Sales NA";
        Rec."PEPPOL 3.0 Service Format" := Rec."PEPPOL 3.0 Service Format"::"PEPPOL 3.0 - Service NA";
        Rec.Modify();
    end;
}
