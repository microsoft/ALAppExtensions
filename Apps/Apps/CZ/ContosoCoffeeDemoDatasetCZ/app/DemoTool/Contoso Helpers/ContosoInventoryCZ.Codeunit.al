// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Inventory.Journal;

codeunit 31222 "Contoso Inventory CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    Permissions = tabledata "Invt. Movement Template CZL" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertInvtMovementTemplate(Name: Code[10]; Description: Text[80]; EntryType: Option; GenBusPostingGroup: Code[20])
    var
        InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
        Exists: Boolean;
    begin
        if InvtMovementTemplateCZL.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;
        InvtMovementTemplateCZL.Init();
        InvtMovementTemplateCZL.Validate(Name, Name);
        InvtMovementTemplateCZL.Validate(Description, Description);
        InvtMovementTemplateCZL.Validate("Entry Type", EntryType);
        InvtMovementTemplateCZL.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);

        if Exists then
            InvtMovementTemplateCZL.Modify(true)
        else
            InvtMovementTemplateCZL.Insert(true);
    end;
}
