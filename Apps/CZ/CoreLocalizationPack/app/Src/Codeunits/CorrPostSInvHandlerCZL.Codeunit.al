// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Sales.Document;

codeunit 11735 "Corr. Post. S.Inv. Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Sales Invoice", OnAfterCreateCorrectiveSalesCrMemo, '', false, false)]
    local procedure SetCreditMemoTypeOnAfterCreateCorrectiveSalesCrMemo(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader."Credit Memo Type CZL" := SalesHeader."Credit Memo Type CZL"::"Internal Correction";
        SalesHeader.Modify();
    end;
}