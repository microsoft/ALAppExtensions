// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.CashFlow.Worksheet;

codeunit 31405 "Sugg. Wksh. Lines Handler CZZ"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        IsSalesAdvanceLettersConsidered: Boolean;
        IsPurchaseAdvanceLettersConsidered: Boolean;

    [EventSubscriber(ObjectType::Report, Report::"Suggest Worksheet Lines", 'OnBeforeNoOptionsChosen', '', false, false)]
    local procedure OnBeforeNoOptionsChosen(var Result: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        Result := not (IsSalesAdvanceLettersConsidered or IsPurchaseAdvanceLettersConsidered);
        IsHandled := not Result;
    end;

    procedure SetSalesAdvanceLettersConsidered(IsConsidered: Boolean)
    begin
        IsSalesAdvanceLettersConsidered := IsConsidered;
    end;

    procedure SetPurchaseAdvanceLettersConsidered(IsConsidered: Boolean)
    begin
        IsPurchaseAdvanceLettersConsidered := IsConsidered;
    end;
}
