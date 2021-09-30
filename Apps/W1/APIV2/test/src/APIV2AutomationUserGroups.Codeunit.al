codeunit 139867 "APIV2 - Automation User Groups"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Api] [User Groups]
    end;

    var
        Assert: Codeunit Assert;
        LibraryPermissions: Codeunit "Library - Permissions";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'userGroups', Locked = true;
        EmptyJSONErr: Label 'JSON should not be empty.';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;


    [Test]
    procedure TestGetUserGroup()
    var
        UserGroup: Record "User Group";
        Response: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can get a user group with a GET request to the service.
        Initialize();

        // [GIVEN] A user group exists in the system.
        LibraryPermissions.CreateUserGroup(UserGroup, LibraryUtility.GenerateRandomCode20(1, Database::"User Group"));
        Commit();

        // [WHEN] The user makes a GET request for a given user group.
        TargetURL := LibraryGraphMgt.CreateTargetURL(UserGroup.SystemId, Page::"APIV2 - Aut. User Groups", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(Response, TargetURL);

        // [THEN] The response text contains the user group information.
        VerifyUserGroupProperties(Response, UserGroup);
    end;

    [Test]
    procedure TestCreateUserGroup()
    var
        UserGroup: Record "User Group";
        TempUserGroup: Record "User Group" temporary;
        RequestBody: Text;
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] User can create a new user group through a POST method.
        Initialize();

        // [GIVEN] The user has constructed a detailed user group JSON object to send to the service
        LibraryPermissions.CreateUserGroup(TempUserGroup, LibraryUtility.GenerateRandomCode20(1, Database::"User Group"));
        RequestBody := GetUserGroupJSON(TempUserGroup);

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Aut. User Groups", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, RequestBody, Response);

        // [THEN] The Contact has been created in the database with all the details
        UserGroup.Get(TempUserGroup.Code);
        VerifyUserGroupProperties(Response, UserGroup);
    end;

    [Test]
    procedure TestModifyUserGroup()
    var
        UserGroup: Record "User Group";
        TempUserGroup: Record "User Group" temporary;
        Response: Text;
        TargetURL: Text;
        RequestBody: Text;
    begin
        // [SCENARIO] User can modify a user group with a GET request to the service.
        Initialize();

        // [GIVEN] A user group exists in the system.
        LibraryPermissions.CreateUserGroup(UserGroup, LibraryUtility.GenerateRandomCode20(1, Database::"User Group"));
        TempUserGroup.TransferFields(UserGroup);
        TempUserGroup.Name := CopyStr(LibraryUtility.GenerateRandomText(50), 1, 50);
        RequestBody := GetUserGroupJSON(TempUserGroup);
        Commit();

        // [WHEN] The user makes a PATCH request for a given user group.
        TargetURL := LibraryGraphMgt.CreateTargetURL(UserGroup.SystemId, Page::"APIV2 - Aut. User Groups", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, RequestBody, Response);

        // [THEN] The response text contains the user group information.
        UserGroup.GetBySystemId(UserGroup.SystemId);
        VerifyUserGroupProperties(Response, TempUserGroup);
    end;

    [Test]
    procedure TestDeleteUserGroup()
    var
        UserGroup: Record "User Group";
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] User cannot delete a user group by making a DELETE request.
        Initialize();

        // [GIVEN] A user group exists in the system.
        LibraryPermissions.CreateUserGroup(UserGroup, LibraryUtility.GenerateRandomCode20(1, Database::"User Group"));
        Commit();

        // [WHEN] The user makes a DELETE request to the endpoint for the Contact.
        TargetURL := LibraryGraphMgt.CreateTargetURL(UserGroup.SystemId, Page::"APIV2 - Aut. User Groups", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Response);

        // [THEN] The response is empty.
        Assert.AreEqual('', Response, 'DELETE response should be empty.');

        // [THEN] The user group is no longer in the database.
        UserGroup.SetRange(Code, UserGroup.Code);
        Assert.IsTrue(UserGroup.IsEmpty(), 'User group should be deleted.');
    end;

    [Test]
    procedure TestDeleteUserGroupWithMember()
    var
        UserGroup: Record "User Group";
        UserGroupMember: Record "User Group Member";
        TargetURL: Text;
        Response: Text;
    begin
        // [SCENARIO] User cannot delete a user group by making a DELETE request.
        Initialize();

        // [GIVEN] A user group exists in the system and it has members.
        LibraryPermissions.CreateUserGroup(UserGroup, LibraryUtility.GenerateRandomCode20(1, Database::"User Group"));
        LibraryPermissions.CreateUserGroupMember(UserGroup, UserGroupMember);
        Commit();

        // [WHEN] The user makes a DELETE request to the endpoint for the Contact.
        TargetURL := LibraryGraphMgt.CreateTargetURL(UserGroup.SystemId, Page::"APIV2 - Aut. User Groups", ServiceNameTxt);
        asserterror LibraryGraphMgt.DeleteFromWebService(TargetURL, '', Response);

        // [THEN] The response is empty.
        Assert.AreEqual('', Response, 'DELETE response should be empty.');

        // [THEN] The user group is still in the database.
        UserGroup.SetRange(Code, UserGroup.Code);
        Assert.IsFalse(UserGroup.IsEmpty(), 'User group should not be deleted.');
    end;

    local procedure VerifyUserGroupProperties(Response: Text; UserGroup: Record "User Group")
    begin
        Assert.AreNotEqual('', Response, EmptyJSONErr);
        LibraryGraphMgt.VerifyIDInJson(Response);
        LibraryGraphMgt.VerifyPropertyInJSON(Response, 'code', UserGroup.Code);
        LibraryGraphMgt.VerifyPropertyInJSON(Response, 'displayName', UserGroup.Name);
        LibraryGraphMgt.VerifyPropertyInJSON(Response, 'defaultProfileID', UserGroup."Default Profile ID");
    end;

    local procedure GetUserGroupJSON(var UserGroup: Record "User Group") UserGroupJSON: Text
    begin
        UserGroupJSON := LibraryGraphMgt.AddPropertytoJSON(UserGroupJSON, 'code', UserGroup.Code);
        UserGroupJSON := LibraryGraphMgt.AddPropertytoJSON(UserGroupJSON, 'displayName', UserGroup.Name);
        UserGroupJSON := LibraryGraphMgt.AddPropertytoJSON(UserGroupJSON, 'defaultProfileID', UserGroup."Default Profile ID");
        UserGroupJSON := LibraryGraphMgt.AddPropertytoJSON(UserGroupJSON, 'assignToAllNewUsers', UserGroup."Assign to All New Users");
        exit(UserGroupJSON)
    end;
}