// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

enum 4815 "Intrastat Report Stat. System"
{
    Extensible = true;
    value(0; " ") { Caption = ' '; }
    value(1; "1-Final Destination") { Caption = '1-Final Destination'; }
    value(2; "2-Temporary Destination") { Caption = '2-Temporary Destination'; }
    value(3; "3-Temporary Destination+Transformation") { Caption = '3-Temporary Destination+Transformation'; }
    value(4; "4-Return") { Caption = '4-Return'; }
    value(5; "5-Return+Transformation") { Caption = '5-Return+Transformation'; }
}