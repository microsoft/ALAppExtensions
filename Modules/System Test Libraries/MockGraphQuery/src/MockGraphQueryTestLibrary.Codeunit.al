// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132927 "MockGraphQuery Test Library"
{
    var
        MockGraphQuery: DotNet MockGraphQuery;
        UserNameTxt: Label '%1 %2', Comment = '%1 - first name, %2 - last name';

    procedure GetMockGraphQuery(MockGraphQueryOut: DotNet MockGraphQuery)
    begin
        MockGraphQueryOut := MockGraphQuery;
    end;

    procedure SetupMockGraphQuery()
    begin
        MockGraphQuery := MockGraphQuery.MockGraphQuery();
    end;

    procedure CreateAzureADUser(var UserInfo: DotNet UserInfo; UserSecurityId: Guid; ObjectId: Text; Surname: Text; DisplayName: Text; Email: Text; PrincipalName: Text; GivenName: Text; PreferredLanguage: Text; AccountEnabled: Boolean)
    begin
        CreateUserProperty(UserSecurityId, ObjectId);

        CreateUserInfo(UserInfo, ObjectId, Surname, DisplayName, Email, PrincipalName,
            GivenName, PreferredLanguage, AccountEnabled);

        MockGraphQuery.AddUser(UserInfo);
    end;

    procedure SetCurrentUser(UserInfo: DotNet UserInfo)
    begin
        MockGraphQuery.CurrentUserUserObject := UserInfo;
    end;

    local procedure CreateUserProperty(UserSecurityId: Guid; AuthenticationObjectId: Text)
    var
        UserProperty: Record "User Property";
    begin
        UserProperty.Init();

        UserProperty."User Security ID" := UserSecurityId;
        UserProperty."Authentication Object ID" := CopyStr(AuthenticationObjectId, 1, 80);

        UserProperty.Insert();
    end;

    procedure CreateUserInfo(var UserInfo: DotNet UserInfo; ObjectId: Text; Surname: Text; DisplayName: Text; Email: Text; PrincipalName: Text; GivenName: Text; PreferredLanguage: Text; AccountEnabled: Boolean)
    begin
        UserInfo := UserInfo.UserInfo();

        UserInfo.ObjectId := ObjectId;
        UserInfo.Surname := Surname;
        UserInfo.DisplayName := DisplayName;
        UserInfo.Mail := Email;
        UserInfo.UserPrincipalName := PrincipalName;
        UserInfo.GivenName := GivenName;
        UserInfo.PreferredLanguage := PreferredLanguage;
        UserInfo.AccountEnabled := AccountEnabled;
    end;

    procedure InsertUser(var User: Record User; UserSecurityId: Guid; Enabled: Boolean; FullName: Text; ContactEmail: Text; AuthenticationEmail: Text; UserName: Text)
    begin
        User.Init();

        User."User Security ID" := UserSecurityId;
        User."Full Name" := CopyStr(FullName, 1, 80);
        User."Contact Email" := CopyStr(ContactEmail, 1, 80);
        User."Authentication Email" := CopyStr(AuthenticationEmail, 1, 80);
        User."User Name" := CopyStr(UserName, 1, 50);

        if Enabled then
            User.State := User.State::Enabled
        else
            User.State := User.State::Disabled;

        User.Insert();
    end;

    procedure SetCurrentUser(UserGivenName: Text; UserEmail: Text)
    var
        GraphUserInfo: DotNet UserInfo;
    begin
        CreateGraphUser(GraphUserInfo, UserSecurityId(), UserGivenName, '', UserEmail);
        MockGraphQuery.CurrentUserUserObject := GraphUserInfo;
    end;

    procedure AddGraphUser(UserId: Text; UserGivenName: Text; UserSurname: Text; UserEmail: Text)
    begin
        AddGraphUser(UserId, UserGivenName, UserSurname, UserEmail, true);
    end;

    procedure AddGraphUser(UserId: Text; UserGivenName: Text; UserSurname: Text; UserEmail: Text; AccountEnabled: Boolean)
    var
        GraphUserInfo: DotNet UserInfo;
    begin
        CreateGraphUser(GraphUserInfo, UserId, UserGivenName, UserSurname, UserEmail, AccountEnabled);
        MockGraphQuery.AddUser(GraphUserInfo);
    end;

    procedure AddAndReturnGraphUser(var GraphUserInfo: DotNet UserInfo; UserId: Text; UserGivenName: Text; UserSurname: Text; UserEmail: Text)
    begin
        CreateGraphUser(GraphUserInfo, UserId, UserGivenName, UserSurname, UserEmail);
        MockGraphQuery.AddUser(GraphUserInfo);
    end;

    procedure AddUserPlan(UserId: Text; AssignedPlanId: Guid; AssignedPlanService: Text; CapabilityStatus: Text)
    var
        GraphUserInfo: DotNet UserInfo;
        AssignedPlan: DotNet ServicePlanInfo;
    begin
        AssignedPlan := AssignedPlan.ServicePlanInfo();
        AssignedPlan.ServicePlanId := AssignedPlanId;
        AssignedPlan.ServicePlanName := AssignedPlanService;
        AssignedPlan.CapabilityStatus := CapabilityStatus;

        GraphUserInfo := MockGraphQuery.GetUserByObjectId(UserId);
        MockGraphQuery.AddAssignedPlanToUser(GraphUserInfo, AssignedPlan);
    end;

    procedure AddDirectoryRole(var DirectoryRole: DotNet RoleInfo; RoleTemplateId: Text; RoleDescription: Text; RoleDisplayName: Text; RoleIsSystem: Boolean)
    begin
        CreateDirectoryRole(DirectoryRole, RoleTemplateId, RoleDescription, RoleDisplayName, RoleIsSystem);
        MockGraphQuery.AddDirectoryRole(DirectoryRole);
    end;

    procedure AddUserRole(UserId: Text; RoleTemplateId: Text; RoleDescription: Text; RoleDisplayName: Text; RoleIsSystem: Boolean)
    var
        GraphUserInfo: DotNet UserInfo;
        DirectoryRole: DotNet RoleInfo;
    begin
        CreateDirectoryRole(DirectoryRole, RoleTemplateId, RoleDescription, RoleDisplayName, RoleIsSystem);

        GraphUserInfo := MockGraphQuery.GetUserByObjectId(UserId);
        MockGraphQuery.AddUserRole(GraphUserInfo, DirectoryRole);
    end;

    procedure AddSubscribedSkuWithServicePlan(SkuId: Guid; PlanId: Guid; PlanName: Text)
    var
        SubscribedSku: DotNet SkuInfo;
        ServicePlanInfo: DotNet ServicePlanInfo;
        GuidVar: Variant;
    begin
        ServicePlanInfo := ServicePlanInfo.ServicePlanInfo();
        GuidVar := PlanId;
        ServicePlanInfo.ServicePlanId := GuidVar;
        ServicePlanInfo.ServicePlanName := PlanName;

        SubscribedSku := SubscribedSku.SkuInfo();
        GuidVar := SkuId;
        SubscribedSku.SkuId := GuidVar;
        SubscribedSku.ServicePlans().Add(ServicePlanInfo);

        AddDirectorySubscribedSku(SubscribedSku);
    end;

    procedure AddDirectorySubscribedSku(SkuInfo: DotNet SkuInfo)
    begin
        MockGraphQuery.AddDirectorySubscribedSku(SkuInfo);
    end;

    procedure GetDirectorySubscribedSkus(DirectorySubscribedSkus: DotNet GenericList1)
    begin
        DirectorySubscribedSkus := MockGraphQuery.GetDirectorySubscribedSkus();
    end;

    procedure PopulateMockGraph(GraphUserInfo: DotNet UserInfo; PlanId: Guid; PlanName: Text)
    var
        DotNetMockGraphQuery: DotNet MockGraphQuery;
    begin
        DotNetMockGraphQuery := DotNetMockGraphQuery.MockGraphQuery();
        DotNetMockGraphQuery.AddUser(GraphUserInfo);
        AddUserPlan(DotNetMockGraphQuery, GraphUserInfo, PlanId, PlanName);
    end;

    local procedure AddUserPlan(var DotNetMockGraphQuery: DotNet MockGraphQuery; GraphUserInfo: DotNet UserInfo; PlanId: Guid; PlanName: Text)
    var
        AssignedPlan: DotNet ServicePlanInfo;
    begin
        AssignedPlan := AssignedPlan.ServicePlanInfo();
        AssignedPlan.ServicePlanId := PlanId;
        AssignedPlan.ServicePlanName := PlanName;
        AssignedPlan.CapabilityStatus := 'Enabled';

        DotNetMockGraphQuery.AddAssignedPlanToUser(GraphUserInfo, AssignedPlan);
    end;

    procedure AddGraphUser(UserId: Text; UserGivenName: Text; UserSurname: Text; UserEmail: Text; AssignedPlanId: Guid; AssignedPlanService: Text; CapabilityStatus: Text)
    var
        GraphUser: DotNet UserInfo;
    begin
        AddGraphUser(GraphUser, UserId, UserGivenName, UserSurname, UserEmail, AssignedPlanId, AssignedPlanService, CapabilityStatus);
    end;

    procedure AddGraphUser(var GraphUser: DotNet UserInfo; UserId: Text; UserGivenName: Text; UserSurname: Text; UserEmail: Text; AssignedPlanId: Guid; AssignedPlanService: Text; CapabilityStatus: Text)
    begin
        CreateGraphUser(GraphUser, UserId, UserGivenName, UserSurname, UserEmail);
        MockGraphQuery.AddUser(GraphUser);
        AddUserPlan(UserId, AssignedPlanId, AssignedPlanService, CapabilityStatus);
    end;

    procedure CreateGraphUser(var GraphUserInfo: DotNet UserInfo; UserId: Text; UserGivenName: Text; UserSurname: Text; UserEmail: Text)
    begin
        CreateGraphUser(GraphUserInfo, UserId, UserGivenName, UserSurname, UserEmail, true);
    end;

    procedure CreateGraphUser(var GraphUserInfo: DotNet UserInfo; UserId: Text; UserGivenName: Text; UserSurname: Text; UserEmail: Text; AccountEnabled: Boolean)
    begin
        GraphUserInfo := GraphUserInfo.UserInfo();
        GraphUserInfo.ObjectId := UserId;
        GraphUserInfo.UserPrincipalName := UserEmail;
        GraphUserInfo.Mail := UserEmail;
        GraphUserInfo.GivenName := UserGivenName;
        GraphUserInfo.Surname := UserSurname;
        GraphUserInfo.AccountEnabled := AccountEnabled;
        GraphUserInfo.DisplayName := StrSubstNo(UserNameTxt, UserGivenName, UserSurname);
    end;

    procedure AddGraphUserWithoutPlan(UserId: Text; UserGivenName: Text; UserSurname: Text; UserEmail: Text)
    var
        GraphUser: DotNet UserInfo;
    begin
        CreateGraphUser(GraphUser, UserId, UserGivenName, UserSurname, UserEmail);
        MockGraphQuery.AddUser(GraphUser);
    end;

    procedure AddGraphUserWithInDevicesGroup(UserId: Text; UserGivenName: Text; UserSurname: Text; UserEmail: Text)
    var
        GraphUser: DotNet UserInfo;
        DevicesGroupInfo: DotNet GroupInfo;
    begin
        CreateGraphUser(GraphUser, UserId, UserGivenName, UserSurname, UserEmail);
        DevicesGroupInfo := DevicesGroupInfo.GroupInfo();
        DevicesGroupInfo.DisplayName := GetDevicesGroupName();
        MockGraphQuery.AddUser(GraphUser);
        MockGraphQuery.AddUserGroup(GraphUser, DevicesGroupInfo);
    end;

    procedure AddGraphUserToDevicesGroup(GraphUser: DotNet UserInfo)
    begin
        AddGraphUserToGroup(GraphUser, GetDevicesGroupName());
    end;

    procedure AddGraphUserToGroup(GraphUser: DotNet UserInfo; GroupName: Text)
    begin
        AddGraphUserToGroup(GraphUser, GroupName, GroupName + ' Object ID');
    end;

    procedure AddGraphUserToGroup(GraphUser: DotNet UserInfo; GroupName: Text; GroupId: Text)
    var
        GroupInfo: DotNet GroupInfo;
    begin
        GroupInfo := GroupInfo.GroupInfo();
        GroupInfo.DisplayName := GroupName;
        GroupInfo.ObjectId := GroupId;
        MockGraphQuery.AddUserGroup(GraphUser, GroupInfo);
    end;

    procedure AddGroup(GroupName: Text; GroupId: Text)
    var
        GroupInfo: DotNet GroupInfo;
    begin
        GroupInfo := GroupInfo.GroupInfo();
        GroupInfo.DisplayName := GroupName;
        GroupInfo.ObjectId := GroupId;
        MockGraphQuery.AddGroup(GroupInfo);
    end;

    local procedure CreateDirectoryRole(var DirectoryRole: DotNet RoleInfo; RoleTemplateId: Text; RoleDescription: Text; RoleDisplayName: Text; RoleIsSystem: Boolean)
    var
        BoolVar: Variant;
    begin
        DirectoryRole := DirectoryRole.RoleInfo();
        DirectoryRole.RoleTemplateId := RoleTemplateId;
        DirectoryRole.DisplayName := RoleDisplayName;
        DirectoryRole.Description := RoleDescription;
        BoolVar := RoleIsSystem;
        DirectoryRole.IsSystem := BoolVar;
    end;

    procedure SetM365CollaborationEnabled(M365CollaborationEnabled: Boolean)
    begin
        MockGraphQuery.M365CollaborationEnabled := M365CollaborationEnabled;
    end;

    procedure GetM365CollaborationEnabled(): Boolean
    begin
        exit(MockGraphQuery.IsM365CollaborationEnabled());
    end;

    procedure SetEnvironmentDirectoryGroup(EnvironmentDirectoryGroup: Text)
    var
        GroupInfo: DotNet GroupInfo;
    begin
        GroupInfo := GroupInfo.GroupInfo();
        GroupInfo.DisplayName := EnvironmentDirectoryGroup;
        // normally the object ID is a GUID, but here we use the group name for simplicity
        GroupInfo.ObjectId := EnvironmentDirectoryGroup + ' Object ID';
        MockGraphQuery.AddGroup(GroupInfo);
        MockGraphQuery.CurrentEnvironmentSecurityGroup := GroupInfo;
    end;

    procedure GetEnvironmentDirectoryGroup(): Text
    begin
        exit(MockGraphQuery.GetEnvironmentDirectoryGroup());
    end;

    local procedure GetDevicesGroupName(): Text
    begin
        exit('Dynamics 365 Business Central Device Users');
    end;
}