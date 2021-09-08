// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132916 "Azure AD Plan Test Library"
{
    Permissions = TableData Plan = rimd,
                   TableData "User Plan" = rimd;

    /// <summary>
    /// Assigns a plan to a user. 
    /// </summary>
    /// <param name="UserID">The user ID.</param>
    /// <param name="PlanID">The plan to assign to the user.</param>
    procedure AssignUserToPlan(UserID: Guid; PlanID: Guid)
    begin
        AssignUserToPlan(UserID, PlanID, false);
    end;
    
    /// <summary>
    /// Assigns a plan to a user.
    /// </summary>
    /// <param name="UserID">The user ID.</param>
    /// <param name="PlanID">The plan to assign to the user.</param>
    /// <param name="Validate">Flag to indicate whether to run the validate trigger.</param>
    procedure AssignUserToPlan(UserID: Guid; PlanID: Guid; Validate: Boolean)
    var
        UserPlan: Record "User Plan";
    begin
        if Validate then begin
            UserPlan.Validate("Plan ID", PlanID);
            UserPlan.Validate("User Security ID", UserID);
        end else begin
            UserPlan."User Security ID" := UserID;
            UserPlan."Plan ID" := PlanID;
        end;

        UserPlan.Insert(true);
    end;

    /// <summary>
    /// Reassign a plan to a user. 
    /// </summary>
    /// <param name="UserID">The user ID.</param>
    /// <param name="PlanID">The plan to reassign to the user.</param>
    procedure ReassignPlanToUser(UserID: Guid; PlanID: Guid)
    var
        UserPlan: Record "User Plan";
    begin
        UserPlan.SetRange("User Security ID", UserID);
        if UserPlan.FindFirst() then
            UserPlan.Rename(PlanID, UserID)
    end;

    /// <summary>
    /// Insert a new plan in the Plan table.
    /// </summary>
    /// <param name="PlanName">The name of the new plan.</param>
    /// <returns>The new plan ID.</returns>
    procedure CreatePlan(PlanName: Text[50]) PlanID: Guid
    var
        Plan: Record Plan;
    begin
        Plan.SetRange(Name, PlanName);
        if Plan.FindFirst() then
            exit(Plan."Plan ID");
        
        PlanID := CreateGuid();
        Plan."Plan ID" := PlanID;
        Plan.Name := PlanName;
        Plan."Role Center ID" := 22; // the value doesn't really matter as long as it's not zero
        
        Plan.Insert(true);
    end;

    /// <summary>
    /// Insert a new plan in the Plan table.
    /// </summary>
    /// <param name="PlanName">The name of the new plan.</param>
    /// <param name="PlanID">The ID of the new plan.</param>
    /// <param name="RoleCenterID">The RoleCenterID of the new plan.</param>
    /// <param name="SystemId">The SystemId of the new plan.</param>
    procedure CreatePlan(PlanGuid: Guid; PlanName: Text[50]; RoleCenterID: Integer; SystemId: Guid)
    var
        Plan: Record Plan;
        AzureADPlan: Codeunit "Azure AD Plan";
    begin
        if AzureADPlan.DoesPlanExist(PlanGuid) then
            exit;

        Plan.Init();
        Plan."Plan ID" := PlanGuid;
        Plan.Name := PlanName;
        Plan."Role Center ID" := RoleCenterID;
        Plan.SystemId := SystemId;
        Plan.Insert(true);
    end;

    /// <summary>
    /// Change the RoleCenterID for a specific plan.
    /// </summary>
    /// <param name="PlanID">The plan ID.</param>
    /// <param name="RoleCenterID">The new RoleCenterID.</param>
    procedure ChangePlanRoleCenterID(PlanID: Guid; RoleCenterID: Integer)
    var
        Plan: Record Plan;
    begin
        Plan.Get(PlanID);
        Plan.Validate("Role Center ID", RoleCenterID);
        Plan.Modify(true);
    end;

    /// <summary>
    /// Delete a specific plan.
    /// </summary>
    /// <param name="PlanID">The plan to delete.</param>
    procedure DeletePlan(PlanName: Text[50])
    var
        Plan: Record Plan;
    begin
        Plan.SetRange(Name, PlanName);
        if Plan.FindFirst() then
            Plan.DeleteAll();
    end;

    /// <summary>
    /// Delete everything from the table Plan.
    /// </summary>
    procedure DeleteAllPlans()
    var
        Plan: Record Plan;
    begin
        Plan.DeleteAll();
    end;

    /// <summary>
    /// Delete everything from the table User Plan.
    /// </summary>
    procedure DeleteAllUserPlan()
    var
        UserPlan: Record "User Plan";
    begin
        UserPlan.DeleteAll();
    end;

    /// <summary>
    /// Delete a user with a specific plan assigned.
    /// </summary>
    /// <param name="UserID">The user to delete.</param>
    /// <param name="PlanID">The plan to delete.</param>
    procedure RemoveUserFromPlan(UserID: Guid; PlanID: Guid)
    var
        UserPlan: Record "User Plan";
    begin
        if UserPlan.Get(PlanID, UserID) then
            UserPlan.Delete(true);
    end;
}