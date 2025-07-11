namespace Mirosoft.Integration.CompanyHub;

entitlement "Delegated BC Admin agent - Partner COHUB"
{
    Type = Role;
    RoleType = Delegated;
    Id = '00000000-0000-0000-0000-000000000010';
    ObjectEntitlements = "Company Hub - Objects",
                         "D365 COMPANY HUB";
}
