namespace Microsoft.CRM.EmailLoggin;

entitlement "Delegated BC Admin agent - Partner Email Logging"
{
    Type = Role;
    RoleType = Delegated;
    Id = '00000000-0000-0000-0000-000000000010';

    ObjectEntitlements = "Email Logging - Read";
}
