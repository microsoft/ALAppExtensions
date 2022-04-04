entitlement "Internal Administrator"
{
    Type = Role;
    RoleType = Local;
    Id = '62e90394-69f5-4237-9190-012177145e10';

#pragma warning disable AL0684
    ObjectEntitlements = "Application Objects - Exec",
                         "Azure AD Plan - Admin",
                         "System Application - Admin";
#pragma warning restore
}
