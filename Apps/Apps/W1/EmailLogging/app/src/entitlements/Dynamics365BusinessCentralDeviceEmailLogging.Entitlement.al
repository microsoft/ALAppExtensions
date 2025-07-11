namespace Microsoft.CRM.EmailLoggin;

entitlement "Dynamics 365 Business Central Device Email Logging"
{
    Type = ConcurrentUserServicePlan;
    GroupName = 'Dynamics 365 Business Central Device Users';
    Id = '100e1865-35d4-4463-aaff-d38eee3a1116';

    ObjectEntitlements = "Email Logging - Admin";
}
