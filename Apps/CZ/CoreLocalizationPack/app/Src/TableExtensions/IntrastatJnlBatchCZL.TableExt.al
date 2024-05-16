// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

#pragma warning disable AL0432
tableextension 31025 "Intrastat Jnl. Batch CZL" extends "Intrastat Jnl. Batch"
#pragma warning restore AL0432
{
    fields
    {
        field(31081; "Declaration No. CZL"; Code[20])
        {
            Caption = 'Declaration No.';
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
#pragma warning disable AL0842
        field(31082; "Statement Type CZL"; Enum "Intrastat Statement Type CZL")
#pragma warning restore AL0842
        {
            Caption = 'Statement Type';
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
    }
}
