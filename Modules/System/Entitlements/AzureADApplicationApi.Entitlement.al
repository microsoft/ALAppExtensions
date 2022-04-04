entitlement "Azure AD Application Api"
{
    Type = ApplicationScope;
    Id = 'API.ReadWrite.All';

#pragma warning disable AL0684
    ObjectEntitlements = "Application Objects - Exec",
                         "System Application - Basic",
                         "Exten. Mgt. - Admin",
                         "Email - Admin",
                         "Feature Key - Admin";
#pragma warning restore                    
}
