// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

codeunit 7277 "Sales Line Suggestions Install"
{
    Subtype = Install;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnInstallAppPerCompany()
    var
        SalesLinesSuggestionsImpl: Codeunit "Sales Lines Suggestions Impl.";
    begin
        SalesLinesSuggestionsImpl.RegisterCapability();
    end;

}