// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.TaxTypeHandler;

codeunit 20236 "Transaction Value Helper"
{
    procedure UpdateCaseID(var SourceRecordRef: RecordRef; TaxType: Code[20]; CaseID: Guid)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Type", TaxType);
        TaxTransactionValue.SetRange("Tax Record ID", SourceRecordRef.RecordId());
        TaxTransactionValue.SetFilter("Case ID", '<>%1', CaseID);
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.ModifyAll("Case ID", CaseID);
    end;
}
