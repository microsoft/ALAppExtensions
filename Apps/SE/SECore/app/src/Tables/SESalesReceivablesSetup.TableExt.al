// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Setup;

tableextension 11291 "SE Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    var
        CompHasTaxAssessCaptionLbl: Label 'Company has Tax Assessment Note';

    procedure GetLegalStatementLabel(): Text
    begin
        exit(CompHasTaxAssessCaptionLbl);
    end;
}
