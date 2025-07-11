// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Sales;

codeunit 18150 "Fin Ch. Memo UseCase Dataset"
{
    procedure GetText(): Text
    begin
        exit(GSTOnFinChMemoUseCasesLbl);
    end;

    var
        GSTOnFinChMemoUseCasesLbl: Label 'GST On Finance Charge Memo Use Cases';
}
