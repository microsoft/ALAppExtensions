// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Setup;

codeunit 11731 "Alt. Cust. VAT Reg. Orch. CZZ"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetAltCustVATRegDocImpl(): Interface "Alt. Cust. VAT Reg. Adv. CZZ"
    var
        VATSetup: Record "VAT Setup";
    begin
        exit(VATSetup.Get() ? VATSetup."Alt. Cust. VAT Reg. Adv. CZZ" : "Alt. Cust. VAT Reg. Adv. CZZ"::Default);
    end;
}