// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Enums;
using Microsoft.DemoTool.Helpers;

codeunit 27038 "Create CA Vat Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure UpdateVATPostingSetup()
    var
        ContosoPostingSetup: Codeunit "Contoso Posting Setup";
    begin
        ContosoPostingSetup.SetOverwriteData(true);
        ContosoPostingSetup.InsertVATPostingSetup('', '', '', '', '', 0, Enum::"Tax Calculation Type"::"Sales Tax", 'E', '', '', false);
        ContosoPostingSetup.SetOverwriteData(true);

        UpdateDescriptionOnVATPostingSetup('', '');
    end;

    local procedure UpdateDescriptionOnVATPostingSetup(VATBusinessGroupCode: Code[20]; VATProductGroupCode: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.Get(VATBusinessGroupCode, VATProductGroupCode);

        VATPostingSetup.Validate(Description, '');
        VATPostingSetup.Modify(true);
    end;
}
