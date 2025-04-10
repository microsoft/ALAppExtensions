// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

enum 5265 "Audit File Export Data Class"
{
    Extensible = true;

    value(0; None) { Caption = 'None'; }
    value(1; MasterData) { Caption = 'Master Data'; }
    value(2; GeneralLedgerEntries) { Caption = 'General Ledger Entries'; }
    value(3; SourceDocuments) { Caption = 'Source Documents'; }
    value(4; Custom) { Caption = 'Custom'; }
}
