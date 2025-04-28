// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Finance.GeneralLedger.Account;

codeunit 27034 "Contoso CA GIFI"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "GIFI Code" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertGIFICode(Code: Code[10]; Name: Text[120])
    var
        GIFICode: Record "GIFI Code";
        Exists: Boolean;
    begin
        if GIFICode.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GIFICode.Validate(Code, Code);
        GIFICode.Validate(Name, Name);

        if Exists then
            GIFICode.Modify(true)
        else
            GIFICode.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}
