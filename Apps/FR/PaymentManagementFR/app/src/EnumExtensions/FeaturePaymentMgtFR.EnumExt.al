#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Bank.Payment;
using System.Environment.Configuration;

enumextension 10831 "Feature - PaymentMgt FR" extends "Feature To Update"
{
    value(10831; Payment)
    {
        Implementation = "Feature Data Update" = "Feature - PaymentMgt FR";
        ObsoleteState = Pending;
        ObsoleteReason = 'Feature Payment Management will be enabled by default in version 31.0.';
        ObsoleteTag = '28.0';
    }
}
#endif