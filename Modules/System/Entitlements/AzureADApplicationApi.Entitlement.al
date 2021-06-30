entitlement "Azure AD Application Api"
{
    Type = ApplicationScope;
    Id = 'API.ReadWrite.All';

    ObjectEntitlements = "Application Objects - Exec",
                         "System Application - Basic",
                         "Exten. Mgt. - Admin",
                         "Email - Admin",
                         "Feature Key - Admin";
}
