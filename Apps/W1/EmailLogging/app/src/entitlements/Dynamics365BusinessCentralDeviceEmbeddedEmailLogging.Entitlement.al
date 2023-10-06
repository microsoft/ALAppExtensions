namespace Microsoft.CRM.EmailLoggin;

entitlement "Dynamics 365 Business Central Device - Embedded Email Logging"
{
    Type = ConcurrentUserServicePlan;
    GroupName = 'Dynamics 365 Business Central Device Users';
    Id = 'a98d0c4a-a52f-4771-a609-e20366102d2a';

    ObjectEntitlements = "Email Logging - Admin";
}
