// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47018 "SL Account Staging Setup"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; Id; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; SalesAccount; Code[20])
        {
        }
        field(3; SalesLineDiscAccount; Code[20])
        {
        }
        field(4; SalesInvDiscAccount; Code[20])
        {
        }
        field(5; SalesPmtDiscDebitAccount; Code[20])
        {
        }
        field(6; PurchAccount; Code[20])
        {
        }
        field(7; PurchInvDiscAccount; Code[20])
        {
        }
        field(8; PurchLineDiscAccount; Code[20])
        {
        }
        field(9; COGSAccount; Code[20])
        {
        }
        field(10; InventoryAdjmtAccount; Code[20])
        {
        }
        field(11; SalesCreditMemoAccount; Code[20])
        {
        }
        field(12; PurchPmtDiscDebitAcc; Code[20])
        {
        }
        field(13; PurchPrepaymentsAccount; Code[20])
        {
        }
        field(14; PurchaseVarianceAccount; Code[20])
        {
        }
        field(15; InventoryAccount; Code[20])
        {
        }
        field(16; ReceivablesAccount; Code[20])
        {
        }
        field(17; ServiceChargeAccount; Code[20])
        {
        }
        field(18; PaymentDiscDebitAccount; Code[20])
        {
        }
        field(19; PayablesAccount; Code[20])
        {
        }
        field(20; PurchServiceChargeAccount; Code[20])
        {
        }
        field(21; PurchPmtDiscDebitAccount; Code[20])
        {
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }
}
