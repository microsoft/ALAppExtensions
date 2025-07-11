

// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance;

enumextension 14600 "IS Docs - Retention Definition" extends "Docs - Retention Period Def."
{
    value(14600; "IS Docs Retention Period")
    {
        Caption = 'IS Docs Retention Period';
        Implementation = "Documents - Retention Period" = "IS Docs Retention Period";
    }
}
