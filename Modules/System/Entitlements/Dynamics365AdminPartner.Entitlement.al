entitlement "Dynamics 365 Admin - Partner"
{
    Type = Role;
    RoleType = Delegated;
    Id = '00000000-0000-0000-0000-000000000009';

#pragma warning disable AL0684
    ObjectEntitlements = "Application Objects - Exec",
                         "System Application - Basic",
                         "Azure AD Plan - Admin",
                         "Security Groups - Admin",
                         "Exten. Mgt. - Admin",
                         "Email - Admin",
                         "Feature Key - Admin";
#pragma warning restore
}
