// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Peppol.BE;

using Microsoft.Peppol;

codeunit 37314 "PEPPOL30 BE Subscribers"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"PEPPOL 3.0 Setup", OnAfterInsertEvent, '', false, false)]
    local procedure OnAfterInsertPEPPOL30Setup(var Rec: Record "PEPPOL 3.0 Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        Rec."PEPPOL 3.0 Sales Format" := Rec."PEPPOL 3.0 Sales Format"::"PEPPOL 3.0 - BE Sales";
        Rec."PEPPOL 3.0 Service Format" := Rec."PEPPOL 3.0 Service Format"::"PEPPOL 3.0 - BE Service";
        Rec.Modify();
    end;
}
