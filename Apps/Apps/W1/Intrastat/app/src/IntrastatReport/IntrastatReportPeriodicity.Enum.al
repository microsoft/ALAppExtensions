// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 4814 "Intrastat Report Periodicity"
{
    Extensible = true;
    value(0; Month) { Caption = 'Month'; }
    value(1; Quarter) { Caption = 'Quarter'; }
    value(2; Year) { Caption = 'Year'; }
}