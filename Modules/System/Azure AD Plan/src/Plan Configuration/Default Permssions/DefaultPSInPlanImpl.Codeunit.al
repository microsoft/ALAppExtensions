#if not CLEAN22
codeunit 9828 "Default PS in Plan Impl"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Default Permission Set In Plan" = r;
    ObsoleteState = Pending;
    ObsoleteReason = 'Getting the default permissions will be done only inside the Azure AD Plan module.';
    ObsoleteTag = '22.0';

    procedure AddPermissionSetToPlan(RoleId: Code[20]; AppId: Guid; Scope: Option)
    begin
        StoredDefaultPermissionSetInPlan.Init();
        StoredDefaultPermissionSetInPlan."Plan ID" := SelectedPlanId;
        StoredDefaultPermissionSetInPlan."Role ID" := RoleId;
        StoredDefaultPermissionSetInPlan.Scope := Scope;
        StoredDefaultPermissionSetInPlan."App ID" := AppId;

        if StoredDefaultPermissionSetInPlan.Insert() then;
    end;

    procedure GetPermissionSets(PlanId: Guid; var DefaultPermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer")
    var
        DefaultPermissionSetInPlan: Record "Default Permission Set In Plan";
        DefaultPermissionSetInPlanCodeunit: Codeunit "Default Permission Set In Plan";
    begin
        SelectedPlanId := PlanId;
        DefaultPermissionSetInPlanBuffer.DeleteAll();
        StoredDefaultPermissionSetInPlan.DeleteAll();

        DefaultPermissionSetInPlanCodeunit.OnGetDefaultPermissions(SelectedPlanId);

        DefaultPermissionSetInPlan.SetRange("Plan ID", SelectedPlanId);
        if DefaultPermissionSetInPlan.FindSet() then
            repeat
                AddPermissionSetToPlan(DefaultPermissionSetInPlan."Role ID", DefaultPermissionSetInPlan."App ID", DefaultPermissionSetInPlan.Scope);
            until DefaultPermissionSetInPlan.Next() = 0;

        if StoredDefaultPermissionSetInPlan.FindSet() then
            repeat
                DefaultPermissionSetInPlanBuffer.TransferFields(StoredDefaultPermissionSetInPlan);
                DefaultPermissionSetInPlanBuffer.Insert();
            until StoredDefaultPermissionSetInPlan.Next() = 0;
    end;

    var
        StoredDefaultPermissionSetInPlan: Record "Permission Set In Plan Buffer";
        SelectedPlanId: Guid;
}
#endif