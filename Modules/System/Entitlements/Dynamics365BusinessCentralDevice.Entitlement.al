entitlement "Dynamics 365 Business Central Device"
{
    Type = ConcurrentUserServicePlan;
    GroupName = 'Dynamics 365 Business Central Device Users';
    Id = '100e1865-35d4-4463-aaff-d38eee3a1116';

#pragma warning disable AL0684
    ObjectEntitlements = "Application Objects - Exec",
                         "Azure AD Plan - Admin",
                         "System Application - Admin";
#pragma warning restore
}
