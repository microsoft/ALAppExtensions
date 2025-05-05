#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using System.Environment.Configuration;

enumextension 10553 "Feature - Reverse Charge VAT" extends "Feature To Update"
{
    value(10553; ReverseChargeVAT)
    {
        Implementation = "Feature Data Update" = "Feature - Reverse Charge VAT";
        ObsoleteState = Pending;
        ObsoleteReason = 'Feature Reverse Charge VAT will be enabled by default in version 30.0.';
        ObsoleteTag = '27.0';
    }
}
#endif