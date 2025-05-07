// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Ledger;

enum 6219 "Sust. Value Type"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Work Center") { Caption = 'Work Center'; }
    value(2; "Machine Center") { Caption = 'Machine Center'; }
    value(3; "Resource") { Caption = 'Resource'; }
    value(4; "Item") { Caption = 'Item'; }
}
