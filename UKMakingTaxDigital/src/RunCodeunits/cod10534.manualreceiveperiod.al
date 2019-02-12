// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10534 "MTD Manual Receive Period"
{
    trigger OnRun()
    var
        GetMTDRecords: Report "Get MTD Records";
        CaptionOption: Option ReturnPeriods,Payments,Liabilities;
    begin
        GetMTDRecords.Initialize(CaptionOption::ReturnPeriods);
        GetMTDRecords.RunModal();
    end;

}
