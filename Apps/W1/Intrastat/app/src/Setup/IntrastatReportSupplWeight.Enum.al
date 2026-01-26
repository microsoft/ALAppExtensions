// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 4821 "Intrastat Report Suppl. Weight"
{
    Extensible = true;
    value(0; " ") { Caption = ' '; }
    value(1; Weight) { Caption = 'Weight'; }
}