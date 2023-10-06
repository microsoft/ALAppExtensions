namespace Mirosoft.Integration.CompanyHub;

entitlement "Dynamics 365 Business Central Device COHUB"
{
    Type = ConcurrentUserServicePlan;
    GroupName = 'Dynamics 365 Business Central Device Users';
    Id = '100e1865-35d4-4463-aaff-d38eee3a1116';
    ObjectEntitlements = "Company Hub - Objects",
                         "D365 COMPANY HUB";
}
