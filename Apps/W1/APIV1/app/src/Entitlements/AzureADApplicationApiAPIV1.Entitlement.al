namespace Microsoft.API.V1;

entitlement "Azure AD Application Api APIV1"
{
    Type = ApplicationScope;
    Id = 'API.ReadWrite.All';
    ObjectEntitlements = "D365 APIV1";
}