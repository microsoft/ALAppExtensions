entitlement "Azure AD Application Automation"
{
    Type = ApplicationScope;
    Id = '00000000-0000-0000-0000-000000000010';

#pragma warning disable AL0684
    ObjectEntitlements = "Application Objects - Exec",
                         "System Application - Basic",
                         "Exten. Mgt. - Admin";
#pragma warning restore
}
