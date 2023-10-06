// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

enum 10670 "SAF-T Mapping Type"
{
    Extensible = true;

    value(0; None) { }
    value(1; "Two Digit Standard Account") { Caption = 'Two Digit Standard Account'; }
    value(2; "Four Digit Standard Account") { Caption = 'Four Digit Standard Account'; }
    value(3; "Income Statement") { Caption = 'Income Statement'; }
}
