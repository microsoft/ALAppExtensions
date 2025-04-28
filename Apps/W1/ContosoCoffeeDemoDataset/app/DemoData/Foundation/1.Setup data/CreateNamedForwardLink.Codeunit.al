// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Utilities;

codeunit 5541 "Create Named Forward Link"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        NamedForwardLink: Record "Named Forward Link";
    begin
        NamedForwardLink.Load();
    end;
}
