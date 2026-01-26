#if not CLEAN28
#pragma warning disable AS0098
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

enumextension 11707 "Feature To Update - CZL" extends "Feature To Update"
{
    value(11700; ReplaceVATPeriod)
    {
        Caption = 'Replace VAT Period';
        Implementation = "Feature Data Update" = "Feature Replace VAT Period CZL";
        ObsoleteState = Pending;
        ObsoleteReason = 'ReplaceVATPeriodCZ removed from Feature Management.';
        ObsoleteTag = '28.0';
    }
}
#endif