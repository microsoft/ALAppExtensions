// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9807 "Field Selection Impl."
{
    Access = Internal;
    Permissions = tabledata Field = r;

    procedure Open(var "Field": Record "Field"): Boolean
    var
        FieldsLookup: Page "Fields Lookup";
    begin
        HideInvalidFields(Field);
        FieldsLookup.SetTableView(Field);
        FieldsLookup.LookupMode(true);
        if FieldsLookup.RunModal() = ACTION::LookupOK then begin
            FieldsLookup.GetSelectedFields(Field);
            exit(true);
        end;
        exit(false);
    end;

    local procedure HideInvalidFields(var "Field": Record "Field")
    begin
        Field.FilterGroup(2);
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.SetRange(Enabled, true);
        Field.FilterGroup(0);
    end;
}

