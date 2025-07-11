// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

enum 5023 "Serv. Decl. VAT Reg. No. Type"
{
    AssignmentCompatibility = true;
    Extensible = true;

    value(0; "VAT Reg. No.") { Caption = 'VAT Reg. No.'; }
    value(1; "Country Code + VAT Reg. No.") { Caption = 'Country Code + VAT Reg. No.'; }
    value(2; "VAT Reg. No. w/o Country Code") { Caption = 'VAT Reg. No. Without Country Code'; }
}
