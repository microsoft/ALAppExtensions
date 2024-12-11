// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 4810 "Intrastat Report Source Type"
{
    Extensible = true;
    value(0; " ") { Caption = ' '; }
    value(1; "Item Entry") { Caption = 'Item Entry'; }
    value(2; "Job Entry") { Caption = 'Job Entry'; }
    value(3; "FA Entry") { Caption = 'FA Entry'; }
}