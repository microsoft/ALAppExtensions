#if not CLEAN27
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Common;

using Microsoft.Finance.VAT.Setup;

codeunit 12169 "Common Module IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "VAT Identifier" = rim;
    ObsoleteReason = 'This codeunit is no longer needed.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';

    [Obsolete('Procedure is moved to codeunit 12220 "Contoso VAT Identifier"', '27.0')]
    procedure InsertVATIdentifier(VATCode: Code[20]; Description: Text[50])
    var
        VATIdentifier: Record "VAT Identifier";
        Exists: Boolean;
    begin
        if VATIdentifier.Get(VATCode) then
            Exists := true;

        VATIdentifier.Validate(Code, VATCode);
        VATIdentifier.Validate(Description, Description);

        if Exists then
            VATIdentifier.Modify(true)
        else
            VATIdentifier.Insert(true);
    end;
}
#endif