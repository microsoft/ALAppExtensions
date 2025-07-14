// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.DemoTool;

enumextension 4844 "Intrastat Contoso Module" extends "Contoso Demo Data Module"
{
    value(4844; "Intrastat Contoso Module")
    {
        Caption = 'Intrastat';
        Implementation = "Contoso Demo Data Module" = "Intrastat Contoso Module";
    }
}
