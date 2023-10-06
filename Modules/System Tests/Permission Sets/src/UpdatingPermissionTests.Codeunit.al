// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Security.AccessControl;

using System.Security.AccessControl;
using System.TestLibraries.Utilities;

codeunit 132446 "Updating Permission Tests"
{
    // [FEATURE] [Permission Sets] [UT]

    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        RoleIdLbl: Label 'Test Set A', Locked = true;
        PermissionSetNotfoundLbl: Label '%1 permission set could not be found.', Comment = '%1 - Permission set name', Locked = true;
        Scope: Option System,Tenant;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RemoveAccessForPermissionLinesPerPermissionType()
    var
        MetadataPermissionSet: Record "Metadata Permission Set";
        TenantPermission: Record "Tenant Permission";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionImpl: Codeunit "Permission Impl.";
        NewRoleId: Code[30];
        NewName: Text;
        AppId: Guid;
        NullGuid: Guid;
        TenantPermissionOriginalCount: Integer;
    begin
        // [SCENARIO] Updating a newly created tenant permission set

        // [GIVEN] An existing permission set and a new role ID and name
        NewRoleId := 'RemoveAccess';
        NewName := 'RemoveAccess';

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";
        PermissionSetRelation.CopyPermissionSet(NewRoleId, NewName, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Flat);

        // [WHEN] removing all permissions
        TenantPermission.SetRange("Role ID", NewRoleId);
        TenantPermission.SetRange("App ID", NullGuid);
        TenantPermissionOriginalCount := TenantPermission.Count;
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'R', TenantPermission."Read Permission"::" ");
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'I', TenantPermission."Insert Permission"::" ");
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'M', TenantPermission."Modify Permission"::" ");
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'D', TenantPermission."Delete Permission"::" ");
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'X', TenantPermission."Execute Permission"::" ");

        // [THEN] all permissions have lost all of the permissions previously assigned
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'R', TenantPermission."Read Permission"::" ");
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'I', TenantPermission."Insert Permission"::" ");
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'M', TenantPermission."Modify Permission"::" ");
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'D', TenantPermission."Delete Permission"::" ");
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'X', TenantPermission."Execute Permission"::" ");
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure RemoveAccessForPermissionLinesForAllPermissionTypes()
    var
        MetadataPermissionSet: Record "Metadata Permission Set";
        TenantPermission: Record "Tenant Permission";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionImpl: Codeunit "Permission Impl.";
        NewRoleId: Code[30];
        NewName: Text;
        AppId: Guid;
        TenantPermissionOriginalCount: Integer;
    begin
        // [SCENARIO] Updating a newly created tenant permission set

        // [GIVEN] An existing permission set and a new role ID and name
        NewRoleId := 'RemoveAccess';
        NewName := 'RemoveAccess';

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";
        PermissionSetRelation.CopyPermissionSet(NewRoleId, NewName, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Flat);

        // [WHEN] removing all permissions for table data
        TenantPermission.SetRange("Object Type", TenantPermission."Object Type"::"Table Data");
        TenantPermissionOriginalCount := TenantPermission.Count;
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, '*', TenantPermission."Read Permission"::" ");

        // [THEN] all permissions have lost all of the permissions previously assigned
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, '*', TenantPermission."Read Permission"::" ");

        // [WHEN] removing all permissions for object types other than table data
        TenantPermission.SetFilter("Object Type", '<>%1', TenantPermission."Object Type"::"Table Data");
        TenantPermissionOriginalCount := TenantPermission.Count;
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, '*', TenantPermission."Read Permission"::" ");

        // [THEN] all permissions have lost all of the permissions previously assigned
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, '*', TenantPermission."Read Permission"::" ");
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddDirectAccessForPermissionLinesPerPermissionType()
    var
        MetadataPermissionSet: Record "Metadata Permission Set";
        TenantPermission: Record "Tenant Permission";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionImpl: Codeunit "Permission Impl.";
        NewRoleId: Code[30];
        NewName: Text;
        AppId: Guid;
        TenantPermissionOriginalCount: Integer;
    begin
        // [SCENARIO] Updating a newly created tenant permission set

        // [GIVEN] An existing permission set and a new role ID and name
        NewRoleId := 'DirectAccess';
        NewName := 'DirectAccess';

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";
        PermissionSetRelation.CopyPermissionSet(NewRoleId, NewName, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Flat);
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, '*', TenantPermission."Read Permission"::" ");

        // [WHEN] adding direct access for table data
        TenantPermission.SetRange("Object Type", TenantPermission."Object Type"::"Table Data");
        TenantPermissionOriginalCount := TenantPermission.Count;
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'R', TenantPermission."Read Permission"::"Yes");
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'I', TenantPermission."Insert Permission"::"Yes");
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'M', TenantPermission."Modify Permission"::"Yes");
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'D', TenantPermission."Delete Permission"::"Yes");

        // [THEN] all permissions have direct access
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'R', TenantPermission."Read Permission"::"Yes");
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'I', TenantPermission."Insert Permission"::"Yes");
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'M', TenantPermission."Modify Permission"::"Yes");
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'D', TenantPermission."Delete Permission"::"Yes");

        // [WHEN] adding direct permissions for object types other than table data
        TenantPermission.SetFilter("Object Type", '<>%1', TenantPermission."Object Type"::"Table Data");
        TenantPermissionOriginalCount := TenantPermission.Count;
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'X', TenantPermission."Execute Permission"::"Yes");

        // [THEN] all permissions have direct permissions
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'X', TenantPermission."Execute Permission"::"Yes");
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddDirectAccessForPermissionLinesForAllPermissionTypes()
    var
        MetadataPermissionSet: Record "Metadata Permission Set";
        TenantPermission: Record "Tenant Permission";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionImpl: Codeunit "Permission Impl.";
        NewRoleId: Code[30];
        NewName: Text;
        AppId: Guid;
        TenantPermissionOriginalCount: Integer;
    begin
        // [SCENARIO] Updating a newly created tenant permission set

        // [GIVEN] An existing permission set and a new role ID and name
        NewRoleId := 'DirectAccess';
        NewName := 'DirectAccess';

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";
        PermissionSetRelation.CopyPermissionSet(NewRoleId, NewName, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Flat);
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, '*', TenantPermission."Read Permission"::" ");

        // [WHEN] adding direct access for table data
        TenantPermission.SetRange("Object Type", TenantPermission."Object Type"::"Table Data");
        TenantPermissionOriginalCount := TenantPermission.Count;
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, '*', TenantPermission."Read Permission"::"Yes");

        // [THEN] all permissions have direct permissions
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, '*', TenantPermission."Read Permission"::"Yes");

        // [WHEN] adding direct permissions for object types other than table data
        TenantPermission.SetFilter("Object Type", '<>%1', TenantPermission."Object Type"::"Table Data");
        TenantPermissionOriginalCount := TenantPermission.Count;
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, '*', TenantPermission."Read Permission"::"Yes");

        // [THEN] all permissions have direct permissions
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, '*', TenantPermission."Read Permission"::"Yes");
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddInDirectAccessForPermissionLinesPerPermissionType()
    var
        MetadataPermissionSet: Record "Metadata Permission Set";
        TenantPermission: Record "Tenant Permission";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionImpl: Codeunit "Permission Impl.";
        NewRoleId: Code[30];
        NewName: Text;
        AppId: Guid;
        TenantPermissionOriginalCount: Integer;
    begin
        // [SCENARIO] Updating a newly created tenant permission set

        // [GIVEN] An existing permission set and a new role ID and name
        NewRoleId := 'InDirectAccess';
        NewName := 'InDirectAccess';

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";
        PermissionSetRelation.CopyPermissionSet(NewRoleId, NewName, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Flat);
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, '*', TenantPermission."Read Permission"::" ");

        // [WHEN] adding indirect access for table data
        TenantPermission.SetRange("Object Type", TenantPermission."Object Type"::"Table Data");
        TenantPermissionOriginalCount := TenantPermission.Count;
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'R', TenantPermission."Read Permission"::"Indirect");
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'I', TenantPermission."Insert Permission"::"Indirect");
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'M', TenantPermission."Modify Permission"::"Indirect");
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'D', TenantPermission."Delete Permission"::"Indirect");

        // [THEN] all permissions have indirect access
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'R', TenantPermission."Read Permission"::"Indirect");
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'I', TenantPermission."Insert Permission"::"Indirect");
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'M', TenantPermission."Modify Permission"::"Indirect");
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'D', TenantPermission."Delete Permission"::"Indirect");

        // [WHEN] adding indirect permissions for object types other than table data
        TenantPermission.SetFilter("Object Type", '<>%1', TenantPermission."Object Type"::"Table Data");
        TenantPermissionOriginalCount := TenantPermission.Count;
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, 'X', TenantPermission."Execute Permission"::"Indirect");

        // [THEN] all permissions have indirect permissions
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, 'X', TenantPermission."Execute Permission"::"Indirect");
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure AddInDirectAccessForPermissionLinesForAllPermissionTypes()
    var
        MetadataPermissionSet: Record "Metadata Permission Set";
        TenantPermission: Record "Tenant Permission";
        PermissionSetRelation: Codeunit "Permission Set Relation";
        PermissionImpl: Codeunit "Permission Impl.";
        NewRoleId: Code[30];
        NewName: Text;
        AppId: Guid;
        TenantPermissionOriginalCount: Integer;
    begin
        // [SCENARIO] Updating a newly created tenant permission set

        // [GIVEN] An existing permission set and a new role ID and name
        NewRoleId := 'InDirectAccess';
        NewName := 'InDirectAccess';

        MetadataPermissionSet.SetRange("Role ID", RoleIdLbl);
        LibraryAssert.IsTrue(MetadataPermissionSet.FindFirst(), StrSubstNo(PermissionSetNotfoundLbl, RoleIdLbl));
        AppId := MetadataPermissionSet."App ID";
        PermissionSetRelation.CopyPermissionSet(NewRoleId, NewName, RoleIdLbl, AppId, Scope::System, Enum::"Permission Set Copy Type"::Flat);
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, '*', TenantPermission."Read Permission"::" ");

        // [WHEN] adding direct access for table data
        TenantPermission.SetRange("Object Type", TenantPermission."Object Type"::"Table Data");
        TenantPermissionOriginalCount := TenantPermission.Count;
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, '*', TenantPermission."Read Permission"::"Indirect");

        // [THEN] all permissions have indirect access
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, '*', TenantPermission."Read Permission"::"Indirect");

        // [WHEN] adding indirect permissions for object types other than table data
        TenantPermission.SetFilter("Object Type", '<>%1', TenantPermission."Object Type"::"Table Data");
        TenantPermissionOriginalCount := TenantPermission.Count;
        PermissionImpl.UpdateSelectedPermissionLines(TenantPermission, '*', TenantPermission."Read Permission"::"Indirect");

        // [THEN] all permissions have indirect permissions
        VerifyTenantPermissionsHavePermissionsAssigned(TenantPermission, TenantPermissionOriginalCount, '*', TenantPermission."Read Permission"::"Indirect");
    end;

    local procedure VerifyTenantPermissionsHavePermissionsAssigned(var TenantPermission: Record "Tenant Permission"; TenantPermissionOriginalCount: Integer; RIMDX: Text[1]; PermissionOption: Option)
    begin
        case RIMDX of
            'R':
                TenantPermission.SetRange("Read Permission", PermissionOption);
            'I':
                TenantPermission.SetRange("Insert Permission", PermissionOption);
            'M':
                TenantPermission.SetRange("Modify Permission", PermissionOption);
            'D':
                TenantPermission.SetRange("Delete Permission", PermissionOption);
            'X':
                TenantPermission.SetRange("Execute Permission", PermissionOption);
            '*':
                if TenantPermission."Object Type" = TenantPermission."Object Type"::"Table Data" then begin
                    TenantPermission.SetRange("Read Permission", PermissionOption);
                    TenantPermission.SetRange("Insert Permission", PermissionOption);
                    TenantPermission.SetRange("Modify Permission", PermissionOption);
                    TenantPermission.SetRange("Delete Permission", PermissionOption);
                end else
                    TenantPermission.SetRange("Execute Permission", PermissionOption);
        end;
        LibraryAssert.AreEqual(TenantPermissionOriginalCount, TenantPermission.Count(), 'Update of tenant permissions failed.');
        TenantPermission.SetRange("Read Permission");
        TenantPermission.SetRange("Insert Permission");
        TenantPermission.SetRange("Modify Permission");
        TenantPermission.SetRange("Delete Permission");
        TenantPermission.SetRange("Execute Permission");
    end;
}