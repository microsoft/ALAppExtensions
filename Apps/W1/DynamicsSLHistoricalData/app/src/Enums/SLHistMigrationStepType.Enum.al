// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

enum 42800 "SL Hist. Migration Step Type"
{
    value(0; "Not Started") { Caption = 'Not Started'; }
    value(1; "Started") { Caption = 'Started'; }
    value(2; "SL GL Accounts") { Caption = 'SL G/L Accounts'; }
    value(3; "SL GL Journal Trx.") { Caption = 'SL G/L Journal Trx.'; }
    value(4; "SL Receivables Trx.") { Caption = 'SL Receivables Trx.'; }
    value(5; "SL Payables Trx.") { Caption = 'SL Payables Trx.'; }
    value(6; "SL Inventory Trx.") { Caption = 'SL Inventory Trx.'; }
    value(7; "SL Purchase Receivables Trx.") { Caption = 'SL Purchase Receivables Trx.'; }
    value(98; "Resetting Data") { Caption = 'Resetting Historical Data'; }
    value(99; Finished) { Caption = 'Finished'; }
}