// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 31197 "Create Post Code CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        NavApp.GetResource(LocalPostCodesTok, FileInStream);
        ContosoPostCodeCZ.SetSource(FileInStream);
        ContosoPostCodeCZ.Import();
    end;

    var
        ContosoPostCodeCZ: XmlPort "Contoso Post Code CZ";
        FileInStream: InStream;
        LocalPostCodesTok: Label 'LocalPostCodes.txt', Locked = true;
}
