entitlement "Dynamics 365 Business Central Device - Embedded"
{
    Type = ConcurrentUserServicePlan;
    GroupName = 'Dynamics 365 Business Central Device Users';
    Id = 'a98d0c4a-a52f-4771-a609-e20366102d2a';

#pragma warning disable AL0684
    ObjectEntitlements = "Application Objects - Exec",
                         "Azure AD Plan - Admin",
                         "System Application - Admin";
#pragma warning restore
}
