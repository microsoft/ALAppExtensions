// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10536 "MTD Receive Submitted"
{
    TableNo = "VAT Return Period";

    trigger OnRun()
    var
        MTDMgt: Codeunit "MTD Mgt.";
        ResponseJson: Text;
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        MTDMgt.RetrieveVATReturns(Rec, ResponseJson, TotalCount, NewCount, ModifiedCount, true);
    end;

}
