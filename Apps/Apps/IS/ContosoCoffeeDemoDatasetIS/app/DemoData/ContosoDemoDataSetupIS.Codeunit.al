// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool;

codeunit 14604 "Contoso Demo Data Setup IS"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    [EventSubscriber(ObjectType::Table, Database::"Contoso Coffee Demo Data Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure LocalDemoDataSetup(var Rec: Record "Contoso Coffee Demo Data Setup")
    begin
        Rec."Country/Region Code" := 'IS';
        Rec."Price Factor" := 120;
    end;
}
