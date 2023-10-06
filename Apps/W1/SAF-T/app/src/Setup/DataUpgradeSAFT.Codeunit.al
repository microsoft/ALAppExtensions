// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

codeunit 5284 "Data Upgrade SAF-T" implements DataUpgradeSAFT
{
    procedure IsDataUpgradeRequired(): Boolean
    begin
        exit(false);
    end;

    procedure GetDataUpgradeDescription(): Text
    begin
    end;

    procedure ReviewDataToUpgrade()
    begin
    end;

    procedure UpgradeData() Result: Boolean
    begin
    end;
}
