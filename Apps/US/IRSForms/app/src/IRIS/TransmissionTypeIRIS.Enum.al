// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

enum 10037 "Transmission Type IRIS"
{
    Extensible = true;

    value(0; "O") { Caption = 'Original'; }
    value(1; "C") { Caption = 'Correction'; }
    value(2; "R") { Caption = 'Replacement'; }
}