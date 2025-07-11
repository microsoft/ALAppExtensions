// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Account;

codeunit 19066 "Create IN GL Acc. Category"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateDescritpionOnGLAccountCategory(17, DividendsLbl);
        UpdateDescritpionOnGLAccountCategory(27, LabourLbl);
    end;

    local procedure UpdateDescritpionOnGLAccountCategory(EntryNo: Integer; Description: Text[80])
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        if GLAccountCategory.Get(EntryNo) then begin
            GLAccountCategory.Validate(Description, Description);
            GLAccountCategory.Modify(true);
        end;
    end;

    var
        DividendsLbl: Label 'Dividends', MaxLength = 80;
        LabourLbl: Label 'Labour', MaxLength = 80;
}
