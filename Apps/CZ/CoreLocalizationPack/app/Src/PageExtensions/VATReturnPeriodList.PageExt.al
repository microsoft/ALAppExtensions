// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

pageextension 31264 "VAT Return Period List CZL" extends "VAT Return Period List"
{
    trigger OnAfterGetCurrRecord()
    begin
        Rec.CheckVATReportDueDateCZL();
    end;
}