// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

pageextension 31265 "VAT Return Period Card CZL" extends "VAT Return Period Card"
{
    trigger OnAfterGetRecord()
    begin
        Rec.CheckVATReportDueDateCZL();
    end;
}