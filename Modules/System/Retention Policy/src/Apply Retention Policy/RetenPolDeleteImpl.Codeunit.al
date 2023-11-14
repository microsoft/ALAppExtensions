// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DataAdministration;

using System.Reflection;

codeunit 3916 "Reten. Pol. Delete. Impl." implements "Reten. Pol. Deleting"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        MissingReadPermissionLbl: Label 'Unable to check number of records to delete due to missing read permission for table %1, %2', Comment = '%1 = table number, %2 = table caption';
        MaxNumberofRecToDeleteNegLbl: Label 'Max. Number of Rec. To Delete is less than 0.';

    procedure DeleteRecords(var RecordRef: RecordRef; var RetenPolDeletingParam: Record "Reten. Pol. Deleting Param" temporary);
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        RecordReference: Codeunit "Record Reference";
        RecordReferenceIndirectPermission: Interface "Record Reference";
    begin
        if RetenPolDeletingParam."Max. Number of Rec. To Delete" < 0 then begin
            RetentionPolicyLog.LogWarning(LogCategory(), MaxNumberofRecToDeleteNegLbl);
            exit;
        end;

        RecordReference.Initialize(RecordRef, RecordReferenceIndirectPermission);

        if not RecordReferenceIndirectPermission.ReadPermission(RecordRef) then
            RetentionPolicyLog.LogWarning(LogCategory(), StrSubstNo(MissingReadPermissionLbl, RecordRef.Number, RecordRef.Caption));

        if not RetenPolDeletingParam."Indirect Permission Required" then
            RecordReferenceIndirectPermission.DeleteAll(RecordRef, true);
        RetenPolDeletingParam."Skip Event Indirect Perm. Req." := not RetenPolDeletingParam."Indirect Permission Required";
        RecordRef.Close();
    end;

    local procedure LogCategory(): Enum "Retention Policy Log Category"
    var
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
    begin
        exit(RetentionPolicyLogCategory::"Retention Policy - Apply");
    end;
}