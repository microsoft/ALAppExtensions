namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using System.Environment.Configuration;
using System.Environment;
using System.Security.AccessControl;
using System.Security.Authentication;
codeunit 6420 "ForNAV Peppol AAD App"
{
    Access = Internal;

    var
        ClientIdTok: Label 'f04e6f6d-8b10-473f-98b1-3cd820b3c90f', Locked = true;
        DescriptionLbl: Label 'Integration with ForNAV Peppol', Locked = true;


    procedure CreateAADApplication(deleteIfExist: Boolean)
    var
        AADApplication: Record "AAD Application";
        AADApplicationInterface: Codeunit "AAD Application Interface";
        EnvironmentInformation: Codeunit "Environment Information";
        AppInfo: ModuleInfo;
        ClientDescription: Text[50];
        ContactInformation: Text[50];
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit;

        if AADApplication.Get(GetClientId()) then
            if deleteIfExist then
                AADApplication.Delete(true)
            else
                exit;

        NavApp.GetCurrentModuleInfo(AppInfo);
        ClientDescription := CopyStr(DescriptionLbl, 1, MaxStrLen(ClientDescription));
        ContactInformation := CopyStr(AppInfo.Publisher, 1, MaxStrLen(ContactInformation));
        AADApplicationInterface.CreateAADApplication(GetClientId(), ClientDescription, ContactInformation, true);

        AADApplication.Get(GetClientId());
        AADApplication."App ID" := AppInfo.PackageId;
        AADApplication."App Name" := CopyStr(AppInfo.Name, 1, MaxStrLen(AADApplication."App Name"));
        AADApplication.Modify();
        AssignPermissionsToAADApplication(AADApplication, GetPermissionSets());
    end;

    procedure GrantAccess()
    var
        AadApplication: Record "AAD Application";
        EnvironmentInformation: Codeunit "Environment Information";
        OAuth2: Codeunit OAuth2;
        HasGrantConsentSucceeded: Boolean;
        PermissionGrantError: Text;
        ConsentFailedErr: Label 'Failed to give consent', Locked = true;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit;

        AadApplication.Get(GetClientId());
        if AadApplication."Permission Granted" then
            exit;

        Commit();
        OAuth2.RequestClientCredentialsAdminPermissions(GetClientId(), 'https://login.microsoftonline.com/common/adminconsent', '', HasGrantConsentSucceeded, PermissionGrantError);
        if not HasGrantConsentSucceeded then
            if PermissionGrantError <> '' then
                Error(PermissionGrantError)
            else
                Error(ConsentFailedErr);
        AadApplication."Permission Granted" := true;
        AadApplication.Modify();
    end;

    local procedure AssignPermissionsToAADApplication(var AADApplication: Record "AAD Application"; PermissionSets: List of [Code[20]])
    var
        PermissionSetName: Code[20];
    begin
        if not UserExists(AADApplication) then
            exit;

        foreach PermissionSetName in PermissionSets do
            AddPermissionSetToUser(AADApplication."User ID", PermissionSetName, '');
    end;

    local procedure AddPermissionSetToUser(UserSecurityID: Guid; RoleID: Code[20]; Company: Text[30])
    var
        AccessControl: Record "Access Control";
        AggregatePermissionSet: Record "Aggregate Permission Set";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityID);
        AccessControl.SetRange("Role ID", RoleID);
        AccessControl.SetRange("Company Name", '');
        // Delete the role if it exist
        AccessControl.DeleteAll(true);

        AggregatePermissionSet.SetRange("Role ID", RoleID);
        if not AggregatePermissionSet.FindFirst() then exit;

        AccessControl.Init();
        AccessControl.Validate("User Security ID", UserSecurityID);
        AccessControl.Validate("Role ID", RoleID);
        AccessControl.Validate("App ID", AggregatePermissionSet."App ID");
        AccessControl.Validate("Company Name", Company);
        AccessControl.Insert(true);
    end;

    local procedure UserExists(var AADApplication: Record "AAD Application"): Boolean
    var
        User: Record User;
    begin
        if IsNullGuid(AADApplication."User ID") then
            exit;

        exit(User.Get(AADApplication."User ID"));
    end;

    local procedure GetPermissionSets() PermissionSets: List of [Code[20]]
    begin
        PermissionSets.Add('ForNAV Peppol Setup');
        PermissionSets.Add('FORNAV ENDPOINT');
    end;

    local procedure GetClientId() Id: Guid
    begin
        Id := ClientIdTok;
    end;
}
