// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Inventory;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.Finance;

codeunit 5301 "Create Assembly Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
        CreateNoSeries: Codeunit "Create No. Series";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoItem.InsertAssemblySetup(true, CreateNoSeries.AssemblyOrders(), CreateNoSeries.AssemblyQuote(), CreateNoSeries.AssemblyBlanketOrders(), CreateNoSeries.PostedAssemblyOrders(), true, true, CreatePostingGroups.DomesticPostingGroup());
    end;
}
