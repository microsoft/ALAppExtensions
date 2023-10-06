// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

enum 5261 "G/L Acc. Mapping Period Type"
{
    Extensible = true;

    value(0; None) { }
    value(1; "Accounting Period") { Caption = 'Accounting Period'; }
    value(2; "Date Range") { Caption = 'Date Range'; }
}
