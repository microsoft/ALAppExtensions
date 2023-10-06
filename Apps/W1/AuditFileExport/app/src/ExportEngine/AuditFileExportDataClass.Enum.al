// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

enum 5265 "Audit File Export Data Class"
{
    Extensible = true;

    value(0; None) { }
    value(1; MasterData) { }
    value(2; GeneralLedgerEntries) { }
    value(3; SourceDocuments) { }
    value(4; Custom) { }
}
