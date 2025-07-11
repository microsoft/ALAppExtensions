// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

enum 10673 "SAF-T Data Check status"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Failed") { Caption = 'Failed'; }
    value(2; "Passed") { Caption = 'Passed'; }
}
